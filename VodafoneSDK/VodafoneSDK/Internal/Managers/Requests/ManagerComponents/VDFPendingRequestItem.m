//
//  VDFHttpResponseHandler.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFPendingRequestItem.h"
#import "VDFLogUtility.h"
#import "VDFCacheObject.h"
#import "VDFHttpConnector.h"
#import "VDFHttpConnectionsQueue.h"
#import "VDFCacheManager.h"
#import "VDFError.h"
#import "VDFBaseConfiguration.h"

@interface VDFPendingRequestItem ()
@property (nonatomic, strong) VDFHttpConnectionsQueue *parentQueue;
@property (nonatomic, strong) VDFCacheManager *cacheManager;
// pending http request to the server
@property (nonatomic, strong) VDFHttpConnector *httpRequest;
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
@property (nonatomic, assign) BOOL isRunning;

- (void)retryRequest;
@end

@implementation VDFPendingRequestItem

- (instancetype)initWithBuilder:(id<VDFRequestBuilder>)builder parentQueue:(VDFHttpConnectionsQueue*)parentQueue cacheManager:(VDFCacheManager*)cacheManager configuration:(VDFBaseConfiguration*)configuration{
    self = [super init];
    if(self) {
        self.configuration = configuration;
        self.builder = builder;
        self.parentQueue = parentQueue;
        self.numberOfRetries = 0;
        self.cacheManager = cacheManager;
        self.httpRequest = [[builder factory] createHttpConnectorRequestWithDelegate:self];
    }
    return self;
}

- (void)startRequest {
    if(!self.isRunning) {
        self.isRunning = YES;
        [self startHttpRequest];
    }
}

- (void)cancelRequest {
// TODO stop running request
//    self.isRunning = NO;
}

#pragma mark -
#pragma mark VDFHttpRequestDelegate implementation
- (void)httpRequest:(VDFHttpConnector*)request onResponse:(NSData*)data withError:(NSError*)error {
    
    VDFLogD(@"On http response");
    VDFLogD(@"For request: \n%@", self.builder);
    VDFLogD(@"Http response code: \n%i", request.lastResponseCode);
    VDFLogD(@"Http response data: \n%@", data);
    VDFLogD(@"Http response data string: \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    id<NSCoding> parsedObject = nil;
    
    @synchronized(self.parentQueue) {
        [[self.builder requestState] updateWithHttpResponseCode:request.lastResponseCode];
        
        // parse retrieved data and update builder:
        if(error == nil) {
            parsedObject = [[self.builder responseParser] parseData:data withHttpResponseCode:request.lastResponseCode];
            [[self.builder requestState] updateWithParsedResponse:parsedObject];
            
            // store response in cache:
            VDFCacheObject *cacheObject = [self.builder.factory createCacheObject];
            if(cacheObject != nil) {
                cacheObject.cacheValue = parsedObject;
                [self.cacheManager cacheObject:cacheObject];
            }
        }
    }
    
    // is it finished ?
    BOOL isRetryNeeded = [[self.builder requestState] isRetryNeeded];
    if(!isRetryNeeded) {
        VDFLogD(@"Request is finished, closing it.");
        // remove this request from queue
        [self safeDequeueRequest];
    }
    
    // responding to all delegates:
    VDFLogD(@"Responding to request delegates started.");
    [[self.builder observersContainer] notifyAllObserversWith:parsedObject error:error];
    VDFLogD(@"Responding to request delegates finished.");
    
    if(isRetryNeeded) {
        [self retryRequest];
    }
}

#pragma mark -
#pragma mark private implementation

- (void)startHttpRequest {
    VDFLogD(@"Starting http request:%@", self.builder);
    
    // starting the request
    NSInteger errorCode = [self.httpRequest startCommunication];
    
    if(errorCode > 0) {
        [self stopRequestWithDomainErrorCode:VDFErrorNoConnection];
    }
    
    VDFLogD(@"Request started.");
}


- (void)stopRequestWithDomainErrorCode:(VDFErrorCode)errorCode {
    
    VDFLogD(@"Stopping request.");
    
    // because of error we need to dequeue this connection:
    [self safeDequeueRequest];
    
    // notify observers:
    NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:errorCode userInfo:nil];
    [[self.builder observersContainer] notifyAllObserversWith:nil error:error];
}

- (void)retryRequest {
    
    VDFLogD(@"Retrying request.");
    self.numberOfRetries++;
    
    if(self.numberOfRetries > self.configuration.maxHttpRequestRetriesCount) {
        VDFLogD(@"We run out of the limit, so need to cancel request:\n%@", self.builder);
        // we run out of the limit, so need to return an error and remove this request:
        [self stopRequestWithDomainErrorCode:VDFErrorConnectionTimeout];
    }
    else {
        
        VDFLogD(@"Dispatching retry request (after %f ms):\n%@", self.configuration.httpRequestRetryTimeSpan, self.builder);
        // we still stay in the limit, so wait and make the request
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.configuration.httpRequestRetryTimeSpan * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            
            // check is ther still waiting delegates
            if([[self.builder observersContainer] count] > 0) {
                [self startHttpRequest];
            }
            else {
                VDFLogD(@"Nobody is waiting, removing request:%@", self.builder);
                // if nobody is waiting, so we can remove this request:
                [self safeDequeueRequest];
            }
        });
    }
    
}

- (void)safeDequeueRequest {
    @synchronized(self.parentQueue) {
        [self.parentQueue dequeueRequestItem:self];
    }
}

@end

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
#import "VDFHttpConnectorResponse.h"
#import "VDFDIContainer.h"
#import "VDFRequestState.h"

@interface VDFPendingRequestItem ()
@property (nonatomic, strong) VDFHttpConnectionsQueue *parentQueue;
@property (nonatomic, strong) VDFCacheManager *cacheManager;
// pending http request to the server
@property (nonatomic, strong) VDFHttpConnector *currentHttpRequest;
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, assign) BOOL isRunning;

- (void)retryRequest;
- (void)startHttpRequest;
- (void)onInternalConnectionError:(VDFErrorCode)errorCode;
- (void)safeDequeueRequest;
- (void)parseAndNotifyWithResponse:(VDFHttpConnectorResponse*)response;
@end

@implementation VDFPendingRequestItem

- (instancetype)initWithBuilder:(id<VDFRequestBuilder>)builder parentQueue:(VDFHttpConnectionsQueue*)parentQueue cacheManager:(VDFCacheManager*)cacheManager diContainer:(VDFDIContainer*)diContainer {
    self = [super init];
    if(self) {
        self.diContainer = diContainer;
        self.builder = builder;
        self.parentQueue = parentQueue;
        self.cacheManager = cacheManager;
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
    if(self.isRunning) {
        self.isRunning = NO;
        if(self.currentHttpRequest != nil && [self.currentHttpRequest isRunning]) {
            [self.currentHttpRequest cancelCommunication];
        }
    }
}

#pragma mark -
#pragma mark VDFHttpRequestDelegate implementation
- (void)httpRequest:(VDFHttpConnector*)request onResponse:(VDFHttpConnectorResponse*)response {
    
    VDFLogD(@"On http response");
    VDFLogD(@"For request: \n%@", self.builder);
    VDFLogD(@"Http response code: \n%i", request.lastResponseCode);
    VDFLogD(@"Http response data: \n%@", response.data);
    VDFLogD(@"Http response data string: \n%@", [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding]);
    VDFLogD(@"Http response headers: \n%@", response.responseHeaders);
    
    [self parseAndNotifyWithResponse:response];
    
    // is it finished ?
    if([[self.builder requestState] isRetryNeeded]) {
        [self retryRequest];
    }
    else {
        VDFLogD(@"Request is finished, closing it.");
        // remove this request from queue
        [self safeDequeueRequest];
    }
}

#pragma mark -
#pragma mark private implementation

- (void)startHttpRequest {
    VDFLogD(@"Starting http request:%@", self.builder);
    
    // starting the request
    self.currentHttpRequest = [self.builder createCurrentHttpConnectorWithDelegate:self];
    NSInteger errorCode = [self.currentHttpRequest startCommunication];
    
    if(errorCode > 0) {
        [self onInternalConnectionError:VDFErrorNoConnection];
    }
}


- (void)onInternalConnectionError:(VDFErrorCode)errorCode {
    
    VDFLogD(@"Stopping request.");
    self.isRunning = NO;
    
    // because of error we need to dequeue this connection:
    [self safeDequeueRequest];
    
    // notify observers:
    NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:errorCode userInfo:nil];
    [[self.builder observersContainer] notifyAllObserversWith:nil error:error];
}

- (void)retryRequest {
    
    VDFLogD(@"Dispatching retry request (after %f ms):\n%@", [[self.builder requestState] retryAfter], self.builder);
    // we still stay in the limit, so wait and make the request
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [[self.builder requestState] retryAfter] * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        
        // check is ther still waiting delegates
        if([[self.builder observersContainer] count] > 0) {
            [self startHttpRequest];
        }
        else {
            VDFLogD(@"Nobody is waiting, removing request:%@", self.builder);
            self.isRunning = NO;
            // if nobody is waiting, so we can remove this request:
            [self safeDequeueRequest];
        }
    });
}

- (void)safeDequeueRequest {
    @synchronized(self.parentQueue) {
        [self.parentQueue dequeueRequestItem:self];
    }
}

- (void)parseAndNotifyWithResponse:(VDFHttpConnectorResponse*)response {
    
    id<NSCoding> parsedObject = nil;
    id<VDFRequestState> requestState = [self.builder requestState];
    
    @synchronized(self.parentQueue) {
        [requestState updateWithHttpResponse:response];
        
        // parse retrieved data and update builder:
        parsedObject = [[self.builder responseParser] parseResponse:response];
        [requestState updateWithParsedResponse:parsedObject];
        
        if(parsedObject != nil) {
            // store response in cache:
            VDFCacheObject *cacheObject = [self.builder.factory createCacheObject];
            if(cacheObject != nil) {
                cacheObject.cacheValue = parsedObject;
                [self.cacheManager cacheObject:cacheObject];
            }
        }
    }
    
    // responding to all delegates:
    NSError *error = requestState.responseError != nil ? requestState.responseError : response.error;
    if(parsedObject != nil || error != nil) {
        VDFLogD(@"Responding to request delegates started.");
        [[self.builder observersContainer] notifyAllObserversWith:parsedObject error:error];
        VDFLogD(@"Responding to request delegates finished.");
    }
}

@end

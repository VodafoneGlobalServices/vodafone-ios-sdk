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
- (void)checkNextStepWithBuilderState;
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
    
    VDFLogI(@"On http response\nFor request url: \n%@\nHttp response code: %i\nHttp response headers: \n%@\nHttp response data string: \n--->%@<---\n",
            request.url, request.lastResponseCode, response.responseHeaders, [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding]);
    VDFLogD(@"For request: \n%@", self.builder);
    
    [self parseAndNotifyWithResponse:response];
    
    [self checkNextStepWithBuilderState];
    
    // wee need to inform any other request if any is waiting for response of currently finished response:
    for (VDFPendingRequestItem *pendingItem in [self.parentQueue allPendingRequests]) {
        if(self != pendingItem && [[pendingItem.builder requestState] canHandleResponse:response ofConnectedBuilder:self.builder]) {
            VDFLogD(@"Informing connected request with response of currently finished request on which is waiting.");
            [pendingItem parseAndNotifyWithResponse:response];
            [pendingItem checkNextStepWithBuilderState];
        }
    }
}

#pragma mark -
#pragma mark private implementation

- (void)startHttpRequest {
    VDFLogD(@"Starting http request:%@", self.builder);
    
    // starting the request
    self.currentHttpRequest = [self.builder createCurrentHttpConnectorWithDelegate:self];
    
    if(![self.currentHttpRequest startCommunication]) {
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
    
    id parsedObject = nil;
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

- (void)checkNextStepWithBuilderState {
    // if we need to wait for another request to finish we stopping this request and waiting for another request
    if(![[self.builder requestState] isConnectedRequestResponseNeeded]) {
        // is it finished ?
        if([[self.builder requestState] isRetryNeeded]) {
            [self retryRequest];
        }
        else {
            VDFLogD(@"Request is finished, closing it.");
            // remove this request from queue
            [self safeDequeueRequest];
            VDFLogD(@"Request is dequeued finished and closed.");
        }
    }
}

@end

//
//  VDFRequestsManager.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFServiceRequestsManager.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnector.h"
#import "VDFSettings+Internal.h"
#import "VDFCacheManager.h"
#import "VDFEnums.h"
#import "VDFNetworkReachability.h"
#import "VDFError.h"
#import "VDFLogUtility.h"

#import "VDFRequestFactory.h"
#import "VDFObserversContainer.h"
#import "VDFResponseParser.h"
#import "VDFRequestState.h"
#import "VDFCacheObject.h"
#import "VDFRequestBuilder.h"

#pragma mark VDFPendingRequestHolder class

@interface VDFPendingRequestHolder : NSObject

// TODO documentation
@property (nonatomic, strong) id<VDFRequestBuilder> builder;
// pending http request to the server
@property (nonatomic, strong) VDFHttpConnector *httpRequest;
// number of all http requests made for this holder
@property (nonatomic, assign) NSInteger numberOfRetries;

@end

@implementation VDFPendingRequestHolder

- (instancetype)init {
    self = [super init];
    if(self) {
//        self.waitingRequests = [[NSMutableArray alloc] init];
        self.numberOfRetries = 0;
    }
    return self;
}

@end

#pragma mark - VDFServiceRequestsManager class

@interface VDFServiceRequestsManager ()
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
// array of VDFPendingRequestHolder objects
@property (nonatomic) NSMutableArray *pendingRequests;

- (void)retryRequest:(VDFPendingRequestHolder*)requestHolder;
- (void)startHttpRequest:(VDFPendingRequestHolder*)requestHolder;
- (void)stopRequest:(VDFPendingRequestHolder*)requestHolder withDomainErrorCode:(VDFErrorCode)errorCode;

@end

@implementation VDFServiceRequestsManager

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        VDFLogD(@"Initializing Service Request Manager");
        self.configuration = configuration;
        self.pendingRequests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)performRequestWithBuilder:(id<VDFRequestBuilder>)builder {
    id<NSCoding> responseCachedObject = nil;
    VDFPendingRequestHolder *requestHolder = nil;
    
    @synchronized(self.pendingRequests) {
        
        BOOL handled = NO;
        
        // check is there any the same request waiting for response
        for (VDFPendingRequestHolder *pendingRequestHolder in self.pendingRequests) {
            if([pendingRequestHolder.builder isEqualToFactoryBuilder:builder]) {
                handled = YES;
                // subscribe for response
                [[pendingRequestHolder.builder observersContainer] registerObserver:[builder observer]];
                VDFLogD(@"Http communication is started for this request, registering this request as observer.");
                break;
            }
        }
        
        if(!handled) {
            // check cache:
            VDFCacheObject *cacheObject = [[builder factory] createCacheObject];
            if(cacheObject != nil && [[VDFSettings sharedCacheManager] isObjectCached:cacheObject]) {
                // our object is cached so we read cache:
                VDFLogD(@"Response Object is cached, so we read this from cache.");
                cacheObject = [[VDFSettings sharedCacheManager] readCacheObject:cacheObject];
                responseCachedObject = cacheObject.cacheValue;
                handled = YES;
            }
        }
        
        if(!handled) {
            VDFLogD(@"Response Object is not cached, so we need to perform http request.");
            
            // creating new request and adding this to queue
            requestHolder = [[VDFPendingRequestHolder alloc] init];
            requestHolder.builder = builder;
            requestHolder.httpRequest = [[builder factory] createHttpConnectorRequestWithDelegate:self];
            
            [self.pendingRequests addObject:requestHolder];
        }
    }
    
    if(requestHolder != nil) {
        // then we need to perform http action
        VDFLogD(@"Starting new http request.");
        [self startHttpRequest:requestHolder];
    }
    
    // if we readed response from cache so we invoking this after synchronization
    if(responseCachedObject != nil) {
        VDFLogD(@"Invoking response delegate with response readed from cache.");
        [[builder observersContainer] notifyAllObserversWith:responseCachedObject error:nil];
    }
}

- (void)clearRequestDelegate:(id<VDFUsersServiceDelegate>)requestDelegate {
    // find all requests with this response delegate object
    @synchronized(self.pendingRequests) {
        // clear all corresponding requests:
        for (VDFPendingRequestHolder *holder in self.pendingRequests) {
            [[holder.builder observersContainer] unregisterObserver:requestDelegate];
        }
    }
}

#pragma mark -
#pragma mark private methods implementation

- (void)retryRequest:(VDFPendingRequestHolder*)requestHolder {
    
    VDFLogD(@"Retrying request.");
    if(requestHolder.numberOfRetries > self.configuration.maxHttpRequestRetriesCount) {
        
        VDFLogD(@"We run out of the limit, so need to cancel request:\n%@", requestHolder.builder);
        // we run out of the limit, so need to return an error and remove this request:
        [self stopRequest:requestHolder withDomainErrorCode:VDFErrorConnectionTimeout];
    }
    else {
        
        VDFLogD(@"Dispatching retry request (after %f ms):\n%@", self.configuration.httpRequestRetryTimeSpan, requestHolder.builder);
        // we still stay in the limit, so wait and make the request
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.configuration.httpRequestRetryTimeSpan * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            
            // check is ther still waiting delegates
            if([[requestHolder.builder observersContainer] count] > 0) {
                [self startHttpRequest:requestHolder];
            }
            else {
                VDFLogD(@"Nobody is waiting, removing request:%@", requestHolder.builder);
                // if nobody is waiting, so we can remove this request:
                [self.pendingRequests removeObject:requestHolder];
            }
        });
    }
}

- (void)startHttpRequest:(VDFPendingRequestHolder*)requestHolder {
    
    VDFLogD(@"Starting http request:%@", requestHolder.builder);
    
    // starting the request
    requestHolder.numberOfRetries++;
    NSInteger errorCode = [requestHolder.httpRequest startCommunication];
    
    if(errorCode > 0) {
        [self stopRequest:requestHolder withDomainErrorCode:VDFErrorNoConnection];
    }
    
    VDFLogD(@"Request started.");
}

- (void)stopRequest:(VDFPendingRequestHolder*)requestHolder withDomainErrorCode:(VDFErrorCode)errorCode {
    
    VDFLogD(@"Stopping request.");
    
    @synchronized(self.pendingRequests) {
        [self.pendingRequests removeObject:requestHolder];
    }
    
    // notify observers:
    NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:errorCode userInfo:nil];
    [[requestHolder.builder observersContainer] notifyAllObserversWith:nil error:error];
}

#pragma mark -
#pragma mark VDFHttpRequestDelegate implementation
- (void)httpRequest:(VDFHttpConnector*)request onResponse:(NSData*)data withError:(NSError *)error {
    
    VDFLogD(@"On http response");
    
    id<NSCoding> parsedObject = nil;
    VDFPendingRequestHolder *pendingRequestHolder = nil;
    
    @synchronized(self.pendingRequests) {
        
        // find proper request holder:
        for (VDFPendingRequestHolder *holder in self.pendingRequests) {
            if(holder.httpRequest == request) {
                pendingRequestHolder = holder;
                break;
            }
        }
        
        VDFLogD(@"For request: \n%@", pendingRequestHolder.builder);
        VDFLogD(@"Http response code: \n%i", request.lastResponseCode);
        VDFLogD(@"Http response data: \n%@", data);
        
        if(pendingRequestHolder != nil) {
            [[pendingRequestHolder.builder requestState] updateWithHttpResponseCode:request.lastResponseCode];
        }
        
        // parse and cache retrieved data:
        if(error == nil && pendingRequestHolder != nil) {
            parsedObject = [[pendingRequestHolder.builder responseParser] parseData:data withHttpResponseCode:request.lastResponseCode];
            [[pendingRequestHolder.builder requestState] updateWithParsedResponse:parsedObject];
            
            VDFCacheObject *cacheObject = [pendingRequestHolder.builder.factory createCacheObject];
            if(cacheObject != nil) {
                cacheObject.cacheValue = parsedObject;
                [[VDFSettings sharedCacheManager] cacheObject:cacheObject];
            }
        }
    }
    
    if(pendingRequestHolder != nil) {
        // responding to all delegates:
        VDFLogD(@"Responding to request delegates started.");
        [[pendingRequestHolder.builder observersContainer] notifyAllObserversWith:parsedObject error:error];
        VDFLogD(@"Responding to request delegates finished.");
        
        // is it finished ?
        if([[pendingRequestHolder.builder requestState] isSatisfied]) {
            VDFLogD(@"Request is finished, closing it.");
            // remove this request from queue
            [self.pendingRequests removeObject:pendingRequestHolder];
        }
        else {
            // if not retry with http pooling
            [self retryRequest:pendingRequestHolder];
        }
    }
}

@end

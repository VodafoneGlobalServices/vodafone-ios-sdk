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

#pragma mark VDFPendingRequestHolder class

@interface VDFPendingRequestHolder : NSObject

// request which started the http request
@property (nonatomic, strong) id<VDFRequest> initialRequest;
// pending http request to the server
@property (nonatomic, strong) VDFHttpConnector *httpRequest;
// list of all requests waiting for the response
@property (nonatomic, strong) NSMutableArray *waitingRequests;

@end

@implementation VDFPendingRequestHolder

- (instancetype)init {
    self = [super init];
    if(self) {
        self.waitingRequests = [[NSMutableArray alloc] init];
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

@end

@implementation VDFServiceRequestsManager

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        self.configuration = configuration;
        self.pendingRequests = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)performRequest:(id<VDFRequest>)request {
    id<NSCoding> responseObject = nil;
    
    @synchronized(self.pendingRequests) {
        // check cache:
        if([request isCachable] && [[VDFSettings sharedCacheManager] isResponseCachedForRequest:request]) {
            // our object is cached so we read cache:
            responseObject = [[VDFSettings sharedCacheManager] responseForRequest:request];
        }
        else {
            BOOL subscribedForResponse = NO;
            
            // check is there any the same request waiting for response
            for (VDFPendingRequestHolder *pendingRequestHolder in self.pendingRequests) {
                if([pendingRequestHolder.initialRequest isEqualToRequest:request]) {
                    subscribedForResponse = YES;
                    // subscribe for response
                    [pendingRequestHolder.waitingRequests addObject:request];
                    break;
                }
            }
            
            if(!subscribedForResponse) {
                // creating new request
                VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:self];
                httpRequest.connectionTimeout = self.configuration.defaultHttpConnectionTimeout;
                
                // and adding this to queue
                VDFPendingRequestHolder *requestHolder = [[VDFPendingRequestHolder alloc] init];
                requestHolder.initialRequest = request;
                requestHolder.httpRequest = httpRequest;
                [requestHolder.waitingRequests addObject:request];
                
                [self.pendingRequests addObject:requestHolder];
                
                [self startHttpRequest:requestHolder];
            }
        }
    }
    
    // if we readed response from cache so we invoking this after synchronization
    if(responseObject != nil) {
        [request onObjectResponse:responseObject withError:nil];
    }
}

- (void)clearRequestDelegate:(id<VDFUsersServiceDelegate>)requestDelegate {
    // find all requests with this response delegate object
    @synchronized(self.pendingRequests) {
        // clear all corresponding requests:
        for (VDFPendingRequestHolder *holder in self.pendingRequests) {
            for (id<VDFRequest> request in holder.waitingRequests) {
                [request clearDelegateIfEquals:requestDelegate];
            }
        }
    }
}

#pragma mark -
#pragma mark private methods implementation

- (void)retryRequest:(VDFPendingRequestHolder*)requestHolder {
    
    // dispatch next request after some time:
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.configuration.httpRequestRetryTimeSpan * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        
        // check is ther still waiting delegates
        BOOL delegatesStillWaiting = NO;
        for (id<VDFRequest> waitingRequest in requestHolder.waitingRequests) {
            if([waitingRequest isDelegateAvailable]) {
                delegatesStillWaiting = YES;
                break;
            }
        }
        if(delegatesStillWaiting) {
            [self startHttpRequest:requestHolder];
        }
        else {
            // if nobody is waiting, so we can remove this request:
            [self.pendingRequests removeObject:requestHolder];
        }
    });
}

- (void)startHttpRequest:(VDFPendingRequestHolder*)requestHolder {
    // starting the request
    NSString * requestUrl = [self.configuration.endpointBaseUrl stringByAppendingString:[requestHolder.initialRequest urlEndpointMethod]];
    if([requestHolder.initialRequest httpMethod] == HTTPMethodPOST) {
        [requestHolder.httpRequest post:requestUrl withBody:[requestHolder.initialRequest postBody]];
    }
    else {
        [requestHolder.httpRequest get:requestUrl];
    }
}

#pragma mark -
#pragma mark VDFHttpRequestDelegate implementation
- (void)httpRequest:(VDFHttpConnector*)request onResponse:(NSData*)data withError:(NSError *)error {
    
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
        
        if(pendingRequestHolder != nil && [pendingRequestHolder.initialRequest respondsToSelector:@selector(onHttpResponseCode:)]) {
            [pendingRequestHolder.initialRequest onHttpResponseCode:request.lastResponseCode];
        }
        
        // parse and cache retrieved data:
        if(error == nil && pendingRequestHolder != nil) {
            parsedObject = [pendingRequestHolder.initialRequest parseAndUpdateOnDataResponse:data];
            if([pendingRequestHolder.initialRequest isCachable]) {
                [[VDFSettings sharedCacheManager] cacheResponseObject:parsedObject forRequest:pendingRequestHolder.initialRequest];
            }
        }
    }
    
    if(pendingRequestHolder != nil) {
        // responding to all delegates:
        for (id<VDFRequest> waitingRequest in pendingRequestHolder.waitingRequests) {
            
            // send http response to all requests except the initial one:
            if(pendingRequestHolder.initialRequest != waitingRequest && [waitingRequest respondsToSelector:@selector(onHttpResponseCode:)]) {
                [pendingRequestHolder.initialRequest onHttpResponseCode:request.lastResponseCode];
            }
            
            [waitingRequest onObjectResponse:parsedObject withError:error];
        }
        
        // is it finished ?
        if([pendingRequestHolder.initialRequest isSatisfied]) {
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

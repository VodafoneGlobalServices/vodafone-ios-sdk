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

#import "VDFHttpConnectionsQueue.h"
#import "VDFPendingRequestItem.h"
#import "VDFDIContainer.h"
#import "VDFRequestCallsCounter.h"


#pragma mark - VDFServiceRequestsManager class

@interface VDFServiceRequestsManager ()
@property (nonatomic, strong) VDFCacheManager *cacheManager;
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) VDFHttpConnectionsQueue *connectionsQueue;
@property (nonatomic, strong) VDFRequestCallsCounter *callsCounter;
@end

@implementation VDFServiceRequestsManager

- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer cacheManager:(VDFCacheManager*)cacheManager {
    self = [super init];
    if(self) {
        VDFLogD(@"Initializing Service Request Manager");
        self.cacheManager = cacheManager;
        self.diContainer = diContainer;
        self.connectionsQueue = [[VDFHttpConnectionsQueue alloc] initWithCacheManager:cacheManager diContainer:diContainer];
        self.callsCounter = [[VDFRequestCallsCounter alloc] initWithDIContainer:diContainer];
    }
    return self;
}

- (void)performRequestWithBuilder:(id<VDFRequestBuilder>)builder {
    
    if(builder == nil) {
        return;
    }
    
    // check dependant request if it is needed:
    BOOL isDependantImplemented = [builder respondsToSelector:@selector(dependentRequestBuilder)] && [builder respondsToSelector:@selector(setResumeTarget:selector:)];
    id<VDFRequestBuilder> dependsOn = isDependantImplemented ? [builder dependentRequestBuilder] : nil;
    if(dependsOn != nil) {
        [builder setResumeTarget:self selector:@selector(performRequestWithBuilder:)];
        [self performRequestWithBuilder:dependsOn];
        
    }
    else {
        id<NSCoding> responseCachedObject = nil;
        @synchronized(self.connectionsQueue) {
            // check cache:
            VDFCacheObject *cacheObject = [[builder factory] createCacheObject];
            if(cacheObject != nil && [self.cacheManager isObjectCached:cacheObject]) {
                // our object is cached so we read cache:
                VDFLogD(@"Response Object is cached, so we read this from cache.");
                responseCachedObject = [self.cacheManager readCacheObject:cacheObject] ;
            }
            else {
                // check for throttling:
                if([self.callsCounter canPerformRequestOfType:[builder class]]) {
                    // add this to queue:
                    [self.callsCounter incrementCallType:[builder class]];
                    [self.connectionsQueue enqueueRequestBuilder:builder];
                }
                else {
                    // invoke with error:
                    NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorThrottlingLimitExceeded userInfo:nil];
                    [[builder observersContainer] notifyAllObserversWith:nil error:error];
                }
            }
        }
        
        // if we readed response from cache so we invoking this after synchronization
        if(responseCachedObject != nil) {
            VDFLogD(@"Invoking response delegate with response readed from cache.");
            [[builder observersContainer] notifyAllObserversWith:responseCachedObject error:nil];
        }
    }
}

- (void)removeRequestObserver:(id)requestDelegate {
    
    if(requestDelegate == nil) {
        return;
    }
    
    // find all requests with this response delegate object
    @synchronized(self.connectionsQueue) {
        NSMutableArray *itemsToRemove = [NSMutableArray array];
        
        // clear all corresponding requests with this registered delegate:
        for (VDFPendingRequestItem *item in [self.connectionsQueue allPendingRequests]) {
            id<VDFObserversContainer> observersContainer = [item.builder observersContainer];
            [observersContainer unregisterObserver:requestDelegate];
            
            // if there is no waiting observers we need to stop request:
            if([observersContainer count] == 0) {
                [itemsToRemove addObject:item];
            }
        }
        
        for (VDFPendingRequestItem *item in itemsToRemove) {
            [self.connectionsQueue dequeueRequestItem:item];
        }
    }
}


@end

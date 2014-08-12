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


#pragma mark - VDFServiceRequestsManager class

@interface VDFServiceRequestsManager ()
@property (nonatomic, strong) VDFCacheManager *cacheManager;
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
@property (nonatomic, strong) VDFHttpConnectionsQueue *connectionsQueue;
@property (nonatomic, strong) NSObject *synchronizationUnit;
@end

@implementation VDFServiceRequestsManager

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration cacheManager:(VDFCacheManager*)cacheManager {
    self = [super init];
    if(self) {
        VDFLogD(@"Initializing Service Request Manager");
        self.cacheManager = cacheManager;
        self.configuration = configuration;
        self.connectionsQueue = [[VDFHttpConnectionsQueue alloc] initWithCacheManager:cacheManager configuration:configuration];
    }
    return self;
}

- (void)performRequestWithBuilder:(id<VDFRequestBuilder>)builder {
    id<NSCoding> responseCachedObject = nil;
    
    @synchronized(self.connectionsQueue) {
        // check cache:
        VDFCacheObject *cacheObject = [[builder factory] createCacheObject];
        if(cacheObject != nil && [self.cacheManager isObjectCached:cacheObject]) {
            // our object is cached so we read cache:
            VDFLogD(@"Response Object is cached, so we read this from cache.");
            responseCachedObject = [self.cacheManager readCacheObject:cacheObject];
        }
        else {
            // add this to queue:
            [self.connectionsQueue enqueueRequestBuilder:builder];
        }
    }
    
    // if we readed response from cache so we invoking this after synchronization
    if(responseCachedObject != nil) {
        VDFLogD(@"Invoking response delegate with response readed from cache.");
        [[builder observersContainer] notifyAllObserversWith:responseCachedObject error:nil];
    }
}

- (void)removeRequestObserver:(id<VDFUsersServiceDelegate>)requestDelegate {
    // find all requests with this response delegate object
    @synchronized(self.connectionsQueue) {
        NSMutableArray *itemsToRemove = [NSMutableArray array];
        
        // clear all corresponding requests with this registered delegate:
        for (VDFPendingRequestItem *item in [self.connectionsQueue allPendingRequests]) {
            [[item.builder observersContainer] unregisterObserver:requestDelegate];
            
            // if there is no waiting observers we need to stop request:
            if([[item.builder observersContainer] count] == 0) {
                [itemsToRemove addObject:item];
            }
        }
        
        for (VDFPendingRequestItem *item in itemsToRemove) {
            [self.connectionsQueue dequeueRequestItem:item];
        }
    }
}


@end

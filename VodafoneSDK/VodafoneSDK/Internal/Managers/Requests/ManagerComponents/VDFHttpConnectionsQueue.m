//
//  VDFHttpConnectionsQueue.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFHttpConnectionsQueue.h"
#import "VDFRequestBuilder.h"
#import "VDFHttpConnector.h"
#import "VDFLogUtility.h"
#import "VDFPendingRequestItem.h"
#import "VDFError.h"
#import "VDFCacheManager.h"
#import "VDFBaseConfiguration.h"

@interface VDFHttpConnectionsQueue ()

// array of VDFPendingRequestItem objects
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, assign) VDFBaseConfiguration *configuration;
@property (nonatomic, strong) VDFCacheManager *cacheManager;

- (VDFPendingRequestItem*)findRequestItemByBuilder:(id<VDFRequestBuilder>)builder;

@end

@implementation VDFHttpConnectionsQueue

- (instancetype)initWithCacheManager:(VDFCacheManager*)cacheManager configuration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        self.pendingRequests = [[NSMutableArray alloc] init];
        self.configuration = configuration;
        self.cacheManager = cacheManager;
    }
    return self;
}

- (VDFPendingRequestItem*)enqueueRequestBuilder:(id<VDFRequestBuilder>)builder {
    
    // check is there any the same request waiting for response:
    VDFPendingRequestItem *requestItem = [self findRequestItemByBuilder:builder];
    if(requestItem != nil) {
        // there is already pending request so lets register obervers to it:
        for (id observer in [[builder observersContainer] registeredObservers]) {
            [[requestItem.builder observersContainer] registerObserver:observer];
        }
        VDFLogD(@"Http communication is started for this request, registering this request as observer.");
    }
    else {
        // we need to start new HTTP request:
        VDFLogD(@"Starting new http request.");
        
        // creating new request and adding this to queue
        requestItem = [[VDFPendingRequestItem alloc] initWithBuilder:builder
                                                         parentQueue:self
                                                        cacheManager:self.cacheManager
                                                       configuration:self.configuration];
        
        [self.pendingRequests addObject:requestItem];
        
        // then we need to perform http action
        [requestItem startRequest];
    }
    
    return requestItem;
}

- (void)dequeueRequestItem:(VDFPendingRequestItem*)requestItem {
    if(requestItem != nil) {
        [requestItem cancelRequest];
        [self.pendingRequests removeObject:requestItem];
    }
}

- (NSArray*)allPendingRequests {
    return self.pendingRequests;
}

#pragma mark -
#pragma mark - Private implementation

- (VDFPendingRequestItem*)findRequestItemByBuilder:(id<VDFRequestBuilder>)builder {
    for (VDFPendingRequestItem *pendingRequestItem in self.pendingRequests) {
        if([pendingRequestItem.builder isEqualToFactoryBuilder:builder]) {
            return pendingRequestItem;
        }
    }
    return nil;
}


@end

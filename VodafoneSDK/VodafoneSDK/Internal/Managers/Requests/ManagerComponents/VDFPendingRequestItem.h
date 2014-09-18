//
//  VDFHttpResponseHandler.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFHttpConnectorDelegate.h"
#import "VDFRequestBuilder.h"

@class VDFHttpConnector, VDFHttpConnectionsQueue, VDFCacheManager, VDFDIContainer;

/**
 *  Class of requests queue item.
 */
@interface VDFPendingRequestItem : NSObject <VDFHttpConnectorDelegate>

/**
 *  Initialize request item.
 *
 *  @param builder      Builder object of request to hold.
 *  @param parentQueue  Parent queue object of this item.
 *  @param cacheManager Cache manager object.
 *  @param diContainer  Dependency Injection container.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithBuilder:(id<VDFRequestBuilder>)builder parentQueue:(VDFHttpConnectionsQueue*)parentQueue cacheManager:(VDFCacheManager*)cacheManager diContainer:(VDFDIContainer*)diContainer;

/**
 *  Builder object of request to hold.
 */
@property (nonatomic, strong) id<VDFRequestBuilder> builder;

/**
 *  Starts request.
 */
- (void)startRequest;

/**
 *  Stops requests.
 */
- (void)cancelRequest;

@end

//
//  VDFCacheManager.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseManager.h"
#import "VDFRequest.h"

@class VDFBaseConfiguration;
@interface VDFCacheManager : VDFBaseManager

/*!
 @abstract
 Initialize Cache manager with specified configuration object.
 
 @param configuration - configuration object
 */
- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration;

/*!
 @abstract
 Check is cached and valid response for particular request.
 
 @param request - request object which is the cache key
 
 @return - YES - response is cached and still valid, NO - response is not cached
 */
- (BOOL)isResponseCachedForRequest:(id<VDFRequest>)request;

/*!
 @abstract
 Read from cache response of particular request.
 
 @param request - request object which is the cahce key
 
 @return - Parsed object of response or nil if there is not cached data
 */
- (id<NSCoding>)responseForRequest:(id<VDFRequest>)request;

/*!
 @abstract
 Write to cache response data with association of specified request object.
 
 @param responseObject - object to store in cache
 
 @param request - request object which is the cache key
 */
- (void)cacheResponseObject:(id<NSCoding>)responseObject forRequest:(id<VDFRequest>)request;

/*!
 @abstract
 Invoked automatically on dealloc of last object, clears the expired data.
 */
- (void)clearExpiredCache;

@end

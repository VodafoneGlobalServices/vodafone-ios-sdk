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

/**
 *  Cache manager class. Is responsible of maintaining cache object.
 */
@interface VDFCacheManager : VDFBaseManager

/**
 *  Initialize Cache manager with specified configuration object.
 *
 *  @param configuration Configuration object.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration;

/**
 *  Check is cached and valid response for particular request.
 *
 *  @param request Request object which is the cache key.
 *
 *  @return YES - response is cached and still valid, NO - response is not cached.
 */
- (BOOL)isResponseCachedForRequest:(id<VDFRequest>)request;

/**
 *  Read from cache response of particular request.
 *
 *  @param request Request object which is the cahce key.
 *
 *  @return Parsed object of response or nil if there is not cached data.
 */
- (id<NSCoding>)responseForRequest:(id<VDFRequest>)request;

/**
 *  Write to cache response data with association of specified request object.
 *
 *  @param responseObject Object to store in cache.
 *  @param request        Request object which is the cache key
 */
- (void)cacheResponseObject:(id<NSCoding>)responseObject forRequest:(id<VDFRequest>)request;

/**
 *  Invoked automatically on dealloc of last object, clears the expired data.
 */
- (void)clearExpiredCache;

@end

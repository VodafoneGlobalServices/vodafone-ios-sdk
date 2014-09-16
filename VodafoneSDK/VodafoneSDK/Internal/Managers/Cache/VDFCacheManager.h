//
//  VDFCacheManager.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseManager.h"

@class VDFDIContainer, VDFCacheObject;

/**
 *  Cache manager class. Is responsible of maintaining cache object. Only in memory.
 */
@interface VDFCacheManager : VDFBaseManager

/**
 *  Initialize Cache manager with specified configuration object.
 *
 *  @param diContainer Dependency injection container.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer;

/**
 *  Check is particular object cached.
 *
 *  @param cacheObject Object of cache entry to find.
 *
 *  @return YES if value is cached, NO - when value is not available in cache
 */
- (BOOL)isObjectCached:(VDFCacheObject*)cacheObject;

/**
 *  Read value from cache entry object.
 *
 *  @param cacheObject Object of cache netry.
 *
 *  @return Cached object (if is available) or nil if is not cache or expired.
 */
- (id)readCacheObject:(VDFCacheObject*)cacheObject;

/**
 *  Stores entry in memory cache.
 *
 *  @param cacheObject Entry object with filled key and value to store.
 */
- (void)cacheObject:(VDFCacheObject*)cacheObject;

@end

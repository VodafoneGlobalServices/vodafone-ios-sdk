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
 *  Cache manager class. Is responsible of maintaining cache object.
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

// TODO documentation
- (BOOL)isObjectCached:(VDFCacheObject*)cacheObject;

- (id)readCacheObject:(VDFCacheObject*)cacheObject;

- (void)cacheObject:(VDFCacheObject*)cacheObject;

@end

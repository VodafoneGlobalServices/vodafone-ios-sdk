//
//  VDFCacheObject.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 22/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Basic cache unit object
 */
@interface VDFCacheObject : NSObject <NSCoding>

/**
 *  Key of the cache entry.
 */
@property (nonatomic, strong) NSString *cacheKey;
/**
 *  Cached value.
 */
@property (nonatomic, strong) id<NSCoding> cacheValue;
/**
 *  Expiration date of cache entry.
 */
@property (nonatomic, strong) NSDate *expirationDate;

/**
 *  Initialize object with value, key and validaity period.
 *
 *  @param value          Object to cache.
 *  @param key            Key of created entry.
 *  @param expirationDate Date of entry expiration.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithValue:(id<NSCoding>)value forKey:(NSString*)key withExpirationDate:(NSDate*)expirationDate;

/*!
 @abstract
    Checks this cache object is still valid.
 */
- (BOOL)isExpired;

@end

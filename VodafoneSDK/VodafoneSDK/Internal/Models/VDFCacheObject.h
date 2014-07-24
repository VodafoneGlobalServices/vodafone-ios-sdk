//
//  VDFCacheObject.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 22/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFCacheObject : NSObject <NSCoding>

@property (nonatomic, strong) NSString *cacheKey;
@property (nonatomic, strong) id<NSCoding> cacheValue;
@property (nonatomic, strong) NSDate *expirationDate;

- (instancetype)initWithValue:(id<NSCoding>)value forKey:(NSString*)key withExpirationDate:(NSDate*)expirationDate;

/*!
 @abstract
    Sets directory where all cache files will be stored.
 */
+ (void)setCacheDirectory:(NSString*)cacheDirectory;

/*!
 @abstract
    Remove stored cache file. Need to be invoked when is removed from cache.
 */
- (void)removeCacheFile;

/*!
 @abstract
    Store cache value to file.
 */
- (void)saveCacheFile;

/*!
 @abstract
    Checks this cache object is still valid.
 */
- (BOOL)isExpired;

@end

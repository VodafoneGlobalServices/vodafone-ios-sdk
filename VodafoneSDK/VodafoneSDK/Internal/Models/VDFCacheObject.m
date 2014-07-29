//
//  VDFCacheObject.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 22/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFCacheObject.h"

static NSString * const CACHE_FILE_NAME_FORMAT = @"%@.dat";

static NSString * const CacheKeyKey = @"key";
static NSString * const ExpirationDateKey = @"expirationDate";

static NSString *g_cacheDirectory = nil;

@interface VDFCacheObject ()
- (NSString*)cachePath;
@end

@implementation VDFCacheObject

+ (void)setCacheDirectory:(NSString*)cacheDirectory {
    g_cacheDirectory = cacheDirectory;
}

#pragma mark -
#pragma mark Instance Properties/Methods

@synthesize cacheValue = _cacheValue;
@synthesize cacheKey = _cacheKey;

- (instancetype)initWithValue:(id<NSCoding>)value forKey:(NSString*)key withExpirationDate:(NSDate*)expirationDate {
    self = [super init];
    if(self) {
        self.cacheKey = key;
        self.cacheValue = value;
        self.expirationDate = expirationDate;
    }
    
    return self;
}

- (void)removeCacheFile {
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePath] error:nil];
}

- (void)saveCacheFile {
    // save value cache file:
    if(_cacheValue != nil) {
        [NSKeyedArchiver archiveRootObject:_cacheValue toFile:[self cachePath]];
    }
}

- (BOOL)isExpired {
    return [self.expirationDate compare:[NSDate date]] == NSOrderedAscending;
}

#pragma mark -
#pragma mark Getters/Setters

- (void)setCacheKey:(NSString*)cacheKey {
    if(self.cacheKey && ![self.cacheKey isEqualToString:cacheKey]) {
        // if cache key is changing we need to rename file:
        // so we loading value:
        if(self.cacheValue) {
            // and if is loaded, remove old file:
            [self removeCacheFile];
        }
    }
    _cacheKey = cacheKey;
}

- (NSString*)cacheKey {
    return _cacheKey;
}

- (void)setCacheValue:(id<NSCoding>)cacheValue {
    _cacheValue = cacheValue;
}

- (id<NSCoding>)cacheValue {
    if(_cacheValue == nil) {
        // need to load from cache
        NSString *path = [self cachePath];
        if(path) {
            self.cacheValue = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
    }
    return _cacheValue;
}

#pragma mark -
#pragma mark - Private methods implemenetation

- (NSString*)cachePath {
    if(self.cacheKey) {
        return [g_cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:CACHE_FILE_NAME_FORMAT, self.cacheKey]];
    }
    return nil;
}

#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        self.cacheKey = [decoder decodeObjectForKey:CacheKeyKey];
        self.expirationDate = [decoder decodeObjectForKey:ExpirationDateKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.cacheKey forKey:CacheKeyKey];
    [encoder encodeObject:self.expirationDate forKey:ExpirationDateKey];
}


@end
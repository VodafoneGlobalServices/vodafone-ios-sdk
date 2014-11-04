//
//  VDFCacheObject.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 22/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFCacheObject.h"
#import "VDFLogUtility.h"

static NSString * const CacheKeyKey = @"key";
static NSString * const ExpirationDateKey = @"expirationDate";

@implementation VDFCacheObject

#pragma mark -
#pragma mark Instance Properties/Methods

- (instancetype)initWithValue:(id)value forKey:(NSString*)key withExpirationDate:(NSDate*)expirationDate {
    self = [super init];
    if(self) {
        self.cacheKey = key;
        self.cacheValue = value;
        self.expirationDate = expirationDate;
    }
    
    return self;
}

- (BOOL)isExpired {
    return [self.expirationDate compare:[NSDate date]] == NSOrderedAscending;
}

@end

//
//  VDFCacheManager.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFCacheManager.h"
#import "VDFBaseConfiguration.h"
#import "VDFErrorUtility.h"
#import "VDFCacheObject.h"
#import "VDFLogUtility.h"
#import "VDFDIContainer.h"

@interface VDFCacheManager ()
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) NSMutableArray *cacheObjects;

- (VDFCacheObject*)findInInternalCache:(NSString*)cacheKey;
@end



@implementation VDFCacheManager

- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer {
    self = [super init];
    if(self) {
        VDFLogD(@"Initializing VDFCacheManager instance.");
        self.diContainer = diContainer;
        
        // load main cache files list:
        self.cacheObjects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isObjectCached:(VDFCacheObject*)cacheObject {
    VDFCacheObject *interlCacheObject = nil;
    if(cacheObject != nil && cacheObject.cacheKey != nil) {
        interlCacheObject = [self findInInternalCache:cacheObject.cacheKey];
    }
    return interlCacheObject != nil;
}

- (id)readCacheObject:(VDFCacheObject*)cacheObject {
    VDFLogD(@"Reading response from cache.");
    VDFCacheObject *interlCacheObject = nil;
    if(cacheObject != nil && cacheObject.cacheKey != nil) {
        interlCacheObject = [self findInInternalCache:cacheObject.cacheKey];
    }
    return interlCacheObject;
}

- (void)cacheObject:(VDFCacheObject*)cacheObject {
    VDFCacheObject *internalCacheObject = nil;
    if(cacheObject != nil && cacheObject.cacheKey != nil) {
        internalCacheObject = [self findInInternalCache:cacheObject.cacheKey];
        
        if(internalCacheObject == nil) {
            VDFLogD(@"Adding new cache object.");
            // create new cache object:
            [self.cacheObjects addObject:cacheObject];
        }
        else {
            internalCacheObject.cacheValue = cacheObject.cacheValue;
            internalCacheObject.expirationDate = cacheObject.expirationDate;
        }
    }
}

#pragma mark -
#pragma mark - private methods implementation

- (VDFCacheObject*)findInInternalCache:(NSString*)cacheKey {
    VDFLogD(@"Searching memory cache for response.");
    
    VDFCacheObject *foundObject = nil;
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    for (VDFCacheObject *interlCacheObject in self.cacheObjects) {
        
        // need to check is this expired or not ?
        if([interlCacheObject isExpired]) {
            [objectsToRemove addObject:interlCacheObject];
        }
        else if([interlCacheObject.cacheKey isEqualToString:cacheKey]) {
            // we found it so we move next
            foundObject = interlCacheObject;
            break;
        }
    }
    
    // remove objects marked to delete
    for (VDFCacheObject *cacheObject in objectsToRemove) {
        VDFLogD(@"Removing cache object because it is out of date.");
        [self.cacheObjects removeObject:cacheObject];
    }
    
    VDFLogD(@"Object was found? : %@", (foundObject != nil ? @"YES":@"NO"));
    
    return foundObject;
}

@end

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

@interface VDFCacheManager ()
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
@property (nonatomic, strong) NSMutableArray *cacheObjects;

/*!
 Check object at specified path is not expired. If expired delete it and create new path for the file
 
 @param - path to the object cache file
 
 @return - Cache object with value
 */
- (VDFCacheObject*)findCorrespondingCacheObject:(VDFCacheObject*)cacheObject;
@end



@implementation VDFCacheManager

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        VDFLogD(@"Initializing VDFCacheManager instance.");
        self.configuration = configuration;
        
        // load main cache files list:
        self.cacheObjects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isObjectCached:(VDFCacheObject*)cacheObject {
    VDFCacheObject *interlCacheObject = [self findCorrespondingCacheObject:cacheObject];
    return interlCacheObject != nil;
}

- (id)readCacheObject:(VDFCacheObject*)cacheObject {
    VDFLogD(@"Reading response from cache.");
    VDFCacheObject *interlCacheObject = [self findCorrespondingCacheObject:cacheObject];
    return interlCacheObject;
}

- (void)cacheObject:(VDFCacheObject*)cacheObject {
    VDFCacheObject *interlCacheObject = [self findCorrespondingCacheObject:cacheObject];
    if(interlCacheObject == nil) {
        VDFLogD(@"Adding new cache object.");
        // create new cache object:
        [self.cacheObjects addObject:cacheObject];
    }
    else {
        interlCacheObject.cacheValue = cacheObject.cacheValue;
    }
}

- (void)clearExpiredCache {
    // TODO think is this needed
    // currently is not used
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    for (VDFCacheObject *cacheObject in self.cacheObjects) {
        
        if([cacheObject isExpired]) {
            // file expired !! we have to remove this from cache
            [objectsToRemove addObject:cacheObject];
        }
    }
    
    // remove objects marked to delete
    for (VDFCacheObject *cacheObject in objectsToRemove) {
        [self.cacheObjects removeObject:cacheObject];
    }
}

#pragma mark -
#pragma mark - private methods implementation

- (VDFCacheObject*)findCorrespondingCacheObject:(VDFCacheObject*)cacheObject {
    VDFLogD(@"Searching memory cache for response.");
    
    VDFCacheObject *foundObject = nil;
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    for (VDFCacheObject *interlCacheObject in self.cacheObjects) {
        if([interlCacheObject.cacheKey isEqualToString:cacheObject.cacheKey]) {
            
            // need to check is this expired or not ?
            if([cacheObject isExpired]) {
                [objectsToRemove addObject:cacheObject];
            }
            else {
                // we found it so we move next
                foundObject = cacheObject;
                break;
            }
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

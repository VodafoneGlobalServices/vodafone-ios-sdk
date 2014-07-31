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

static NSString * const CACHE_ARRAY_FILE_NAME = @"cache.dat";

@interface VDFCacheManager ()
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
@property (nonatomic, strong) NSMutableArray *cacheObjects;
@property (nonatomic, strong) NSString *cacheArrayPath;

/*!
 Check object at specified path is not expired. If expired delete it and create new path for the file
 
 @param - path to the object cache file
 
 @return - Cache object with value
 */
- (VDFCacheObject*)findCacheObjectForRequest:(id<VDFRequest>)request;
@end



@implementation VDFCacheManager

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        VDFLogD(@"Initializing VDFCacheManager instance.");
        VDFLogD(@"Cache dir path: %@", configuration.cacheDirectoryPath);
        self.configuration = configuration;
        
        // initialize CacheObject:
        [VDFCacheObject setCacheDirectory:configuration.cacheDirectoryPath];
        
        // load main cache files list:
        self.cacheArrayPath = [self.configuration.cacheDirectoryPath stringByAppendingPathComponent:CACHE_ARRAY_FILE_NAME];
        if([[NSFileManager defaultManager] isReadableFileAtPath:self.cacheArrayPath]) {
            self.cacheObjects = [NSKeyedUnarchiver unarchiveObjectWithFile:self.cacheArrayPath];
        }
        else {
            self.cacheObjects = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (BOOL)isResponseCachedForRequest:(id<VDFRequest>)request {
    VDFCacheObject *cacheObject = [self findCacheObjectForRequest:request];
    return cacheObject != nil;
}

- (id<NSCoding>)responseForRequest:(id<VDFRequest>)request {
    VDFLogD(@"Reading response from cache.");
    VDFCacheObject *cacheObject = [self findCacheObjectForRequest:request];
    return cacheObject.cacheValue;
}

- (void)cacheResponseObject:(id<NSCoding>)responseObject forRequest:(id<VDFRequest>)request {
    VDFCacheObject *cacheObject = [self findCacheObjectForRequest:request];
    if(cacheObject == nil) {
        VDFLogD(@"Creating new cache object.");
        // create new cache object:
        cacheObject = [[VDFCacheObject alloc] initWithValue:responseObject forKey:[request md5Hash] withExpirationDate:[request expirationDate]];
        [self.cacheObjects addObject:cacheObject];
        // save cache array:
        [NSKeyedArchiver archiveRootObject:self.cacheObjects toFile:self.cacheArrayPath];
    }
    else {
        cacheObject.cacheValue = responseObject;
    }
    
    // save cache object:
    [cacheObject saveCacheFile];
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
        [cacheObject removeCacheFile];
        [self.cacheObjects removeObject:cacheObject];
    }
}

#pragma mark -
#pragma mark - private methods implementation

- (VDFCacheObject*)findCacheObjectForRequest:(id<VDFRequest>)request {
    VDFLogD(@"Searching memory cache for response.");
    NSString *requestHash = [request md5Hash];
    
    VDFCacheObject *foundObject = nil;
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    for (VDFCacheObject *cacheObject in self.cacheObjects) {
        if([cacheObject.cacheKey isEqualToString:requestHash]) {
            
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
        [cacheObject removeCacheFile];
        [self.cacheObjects removeObject:cacheObject];
    }
    
    VDFLogD(@"Object was found? : %@", (foundObject != nil ? @"YES":@"NO"));
    
    return foundObject;
}

@end

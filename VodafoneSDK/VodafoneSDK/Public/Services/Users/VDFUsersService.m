//
//  VDFUsersService.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 07/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersService.h"
#import "VDFUserTokenDetails.h"
#import "VDFUserResolveOptions.h"
#import "VDFSettings+Internal.h"
#import "VDFBaseConfiguration.h"
#import "VDFServiceRequestsManager.h"
#import "VDFCacheManager.h"
#import "VDFErrorUtility.h"
#import "VDFUserResolveRequestBuilder.h"
#import "VDFRequestFactory.h"
#import "VDFCacheObject.h"
#import "VDFSmsValidationRequestBuilder.h"

@implementation VDFUsersService

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)retrieveUserDetails:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // create request object
    NSString * applicationId = [VDFSettings configuration].applicationId;
    if(applicationId == nil) {
        applicationId = [NSString string];
    }
    if(options == nil) {
        options = [[VDFUserResolveOptions alloc] init];
    }
    
    VDFUserResolveRequestBuilder *builder = [[VDFUserResolveRequestBuilder alloc] initWithApplicationId:applicationId withOptions:options withConfiguration:[VDFSettings configuration] delegate:delegate];
    
    // get http request manager
    VDFServiceRequestsManager * requestsManager = [VDFSettings sharedRequestsManager];
    
    // perform request call
    [requestsManager performRequestWithBuilder:builder];
}

- (VDFUserTokenDetails*)getUserDetails:(VDFUserResolveOptions*)options {
    
    // create request object
    NSString * applicationId = [VDFSettings configuration].applicationId;
    if(applicationId == nil) {
        applicationId = [NSString string];
    }
    if(options == nil) {
        options = [[VDFUserResolveOptions alloc] init];
    }
    
    VDFUserResolveRequestBuilder *builder = [[VDFUserResolveRequestBuilder alloc] initWithApplicationId:applicationId withOptions:options withConfiguration:[VDFSettings configuration] delegate:nil];
    
    VDFUserTokenDetails *userDetails = nil;
    VDFCacheObject *cacheObject = [[builder factory] createCacheObject];
    
    if([[VDFSettings sharedCacheManager] isObjectCached:cacheObject]) {
        userDetails = (VDFUserTokenDetails*)[[VDFSettings sharedCacheManager] readCacheObject:cacheObject];
        if(![userDetails isKindOfClass:[VDFUserTokenDetails class]]) {
            userDetails = nil;
        }
    }
    return userDetails;
}

- (void)validateSMSToken:(NSString*)smsCode withSessionToken:(NSString*)sessionToken delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // create request object
    NSString * applicationId = [VDFSettings configuration].applicationId;
    if(applicationId == nil) {
        applicationId = [NSString string];
    }
    
    VDFSmsValidationRequestBuilder *builder = [[VDFSmsValidationRequestBuilder alloc] initWithApplicationId:applicationId sessionToken:sessionToken smsCode:smsCode withConfiguration:[VDFSettings configuration] delegate:delegate];
    
    // get http request manager
    VDFServiceRequestsManager * requestsManager = [VDFSettings sharedRequestsManager];
    
    // perform request call
    [requestsManager performRequestWithBuilder:builder];
}

- (void)removeDelegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // get http request manager
    VDFServiceRequestsManager * requestsManager = [VDFSettings sharedRequestsManager];
    
    // inform about request remove
    [requestsManager removeRequestObserver:delegate];
}

@end

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
#import "VDFUserResolveRequest.h"
#import "VDFSettings+Internal.h"
#import "VDFBaseConfiguration.h"
#import "VDFServiceRequestsManager.h"
#import "VDFCacheManager.h"
#import "VDFErrorUtility.h"
#import "VDFSmsValidationRequest.h"

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
    
    VDFUserResolveRequest *request = [[VDFUserResolveRequest alloc] initWithApplicationId:applicationId withOptions:options delegate:delegate];
    
    // get http request manager
    VDFServiceRequestsManager * requestsManager = [VDFSettings sharedRequestsManager];
    
    // perform request call
    [requestsManager performRequest:request];
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
    
    VDFUserResolveRequest *request = [[VDFUserResolveRequest alloc] initWithApplicationId:applicationId withOptions:options delegate:nil];
    VDFUserTokenDetails *userDetails = nil;
    
    if([[VDFSettings sharedCacheManager] isResponseCachedForRequest:request]) {
        userDetails = (VDFUserTokenDetails*)[[VDFSettings sharedCacheManager] responseForRequest:request];
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
    
    VDFSmsValidationRequest *request = [[VDFSmsValidationRequest alloc] initWithApplicationId:applicationId
                                                                                 sessionToken:sessionToken
                                                                                      smsCode:smsCode
                                                                                     delegate:delegate];
    
    // get http request manager
    VDFServiceRequestsManager * requestsManager = [VDFSettings sharedRequestsManager];
    
    // perform request call
    [requestsManager performRequest:request];
}

- (void)removeDelegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // get http request manager
    VDFServiceRequestsManager * requestsManager = [VDFSettings sharedRequestsManager];
    
    // inform about request remove
    [requestsManager clearRequestDelegate:delegate];
}

@end

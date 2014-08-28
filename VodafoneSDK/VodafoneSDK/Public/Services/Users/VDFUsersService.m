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
#import "VDFSmsSendPinRequestBuilder.h"
#import "VDFRequestBuilderWithOAuth.h"
#import "VDFDIContainer.h"

@interface VDFUsersService ()
@property (nonatomic, strong) VDFDIContainer *diContainer;
@end

@implementation VDFUsersService

+ (instancetype)sharedInstance {
    static VDFUsersService *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.diContainer = [VDFSettings globalDIContainer];
    });
    
    return sharedInstance;
}

- (void)retrieveUserDetails:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // create request object
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    NSString * applicationId = configuration.applicationId;
    if(applicationId == nil) {
        applicationId = [NSString string];
    }
    if(options == nil) {
        options = [[VDFUserResolveOptions alloc] init];
    }
    
    id builder = [[VDFUserResolveRequestBuilder alloc] initWithApplicationId:applicationId withOptions:options diContainer:self.diContainer delegate:delegate];
    
    id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
    
    [[VDFSettings sharedRequestsManager] performRequestWithBuilder:builderWithOAuth];
}

- (void)sendSmsPinWithSession:(NSString*)sessionToken delegate:(id<VDFUsersServiceDelegate>)delegate {
    // create request object
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    NSString * applicationId = configuration.applicationId;
    if(applicationId == nil) {
        applicationId = [NSString string];
    }
    
    id builder = [[VDFSmsSendPinRequestBuilder alloc] initWithApplicationId:applicationId sessionToken:sessionToken diContainer:self.diContainer delegate:delegate];
    
    id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
    
    [[VDFSettings sharedRequestsManager] performRequestWithBuilder:builderWithOAuth];
}

- (void)validateSmsPin:(NSString*)smsPin withSessionToken:(NSString*)sessionToken delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // create request object
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    NSString * applicationId = configuration.applicationId;
    if(applicationId == nil) {
        applicationId = [NSString string];
    }
    
    VDFSmsValidationRequestBuilder *builder = [[VDFSmsValidationRequestBuilder alloc] initWithApplicationId:applicationId sessionToken:sessionToken smsCode:smsPin diContainer:self.diContainer delegate:delegate];
    
    id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
    
    [[VDFSettings sharedRequestsManager] performRequestWithBuilder:builderWithOAuth];
}

- (void)removeDelegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // get http request manager
    VDFServiceRequestsManager * requestsManager = [VDFSettings sharedRequestsManager];
    
    // inform about request remove
    [requestsManager removeRequestObserver:delegate];
}

@end

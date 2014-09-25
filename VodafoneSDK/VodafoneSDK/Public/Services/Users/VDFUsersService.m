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
#import "VDFUserResolveOptions+Internal.h"
#import "VDFDeviceUtility.h"

@interface VDFUsersService () <VDFUsersServiceDelegate>
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) NSString *currentSessionToken;
@property (nonatomic, strong) VDFUserResolveRequestBuilder *currentResolveBuilder;
@property (nonatomic, assign) id<VDFUsersServiceDelegate> currentDelegate;

- (NSError*)checkPotentialHAPResolveError;
- (NSError*)updateResolveOptionsAndCheckMSISDNForError:(VDFUserResolveOptions*)options;
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
    
    if(delegate != nil && self.currentSessionToken == nil && self.currentResolveBuilder == nil) {
        // create request object
        if(options == nil) {
            options = [[VDFUserResolveOptions alloc] init];
        }
        
        NSError *error = nil;
        if(options.msisdn == nil) {
            error = [self checkPotentialHAPResolveError];
        }
        else {
            // msisdn is provided
            error = [self updateResolveOptionsAndCheckMSISDNForError:options];
        }
        
        if(error != nil) {
            // there is error so we cannot start the request
            [delegate didReceivedUserDetails:nil withError:error];
        }
        else {
            // everything looks fine, move forward
            
            VDFUserResolveRequestBuilder *builder = [[VDFUserResolveRequestBuilder alloc] initWithOptions:options diContainer:self.diContainer delegate:delegate];
            [[builder observersContainer] registerObserver:self];
            self.currentResolveBuilder = builder;
            self.currentDelegate = delegate;
            
            id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
            
            [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
        }
    }
}

- (void)sendSmsPin {
    
    if(self.currentSessionToken != nil && self.currentResolveBuilder != nil) {
        // create request object
        id builder = [[VDFSmsSendPinRequestBuilder alloc] initWithSessionToken:self.currentSessionToken diContainer:self.diContainer delegate:self.currentDelegate];
        
        id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
        
        [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
    }
}

- (void)validateSmsCode:(NSString*)smsCode {
    
    if(self.currentSessionToken != nil && self.currentResolveBuilder != nil) {
        // create request object
        if(smsCode == nil) {
            smsCode = [NSString string];
        }
        
        // create request object
        id builder = [[VDFSmsValidationRequestBuilder alloc] initWithSessionToken:self.currentSessionToken smsCode:smsCode diContainer:self.diContainer delegate:self.currentDelegate];
        
        id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
        
        [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
    }
}

- (void)setDelegate:(id<VDFUsersServiceDelegate>)delegate {
    
    if(self.currentResolveBuilder != nil) {
        // first step is to register new delegate:
        if(delegate != nil) {
            [[self.currentResolveBuilder observersContainer] registerObserver:delegate];
        }
        
        // next step removes old delegate:
        if(self.currentDelegate != nil) {
            // get http request manager
            VDFServiceRequestsManager * requestsManager = [self.diContainer resolveForClass:[VDFServiceRequestsManager class]];
            
            // inform request manager about removal
            [requestsManager removeRequestObserver:self.currentDelegate];
        }
        
        // store new delegate
        self.currentDelegate = delegate;
    }
}

- (void)cancelRetrieveUserDetails {
    
    if(self.currentResolveBuilder != nil) {
        // if there is pending request we need to cancel request by removing all delegates:
        VDFServiceRequestsManager * requestsManager = [self.diContainer resolveForClass:[VDFServiceRequestsManager class]];
        
        if(self.currentDelegate != nil) {
            // inform request manager about removal
            [requestsManager removeRequestObserver:self.currentDelegate];
        }
        
        // and service class need to be removed
        [requestsManager removeRequestObserver:self];
        
        self.currentDelegate = nil;
        self.currentResolveBuilder = nil;
        self.currentSessionToken = nil;
    }
}

#pragma mark -
#pragma mark - Private Implementation
- (NSError*)checkPotentialHAPResolveError {
    NSString *mccMnc = [VDFDeviceUtility simMccMnc];
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    if(mccMnc != nil) {
        if(![configuration.availableMccMnc containsObject:mccMnc]) {
            return [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorOutOfVodafoneCellular userInfo:nil];
        }
    }
    else {
        return [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoGSMConnection userInfo:nil];
    }
    return nil;
}

- (NSError*)updateResolveOptionsAndCheckMSISDNForError:(VDFUserResolveOptions*)options {
    // we need to read market code from msisdn
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    options.market = [VDFDeviceUtility findMarketForMsisdn:options.msisdn inMarkets:configuration.availableMarkets];
    
    if(options.market == nil) {
        // this phone number is not available for user resolve:
        return [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorMsisdnCountryNotSupported userInfo:nil];
    }
    return nil;
}

#pragma mark -
#pragma mark - VDFUsersServiceDelegate Implementation

- (void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error {
    if(userDetails != nil) {
        if(userDetails.resolutionStatus == VDFResolutionStatusCompleted
           || userDetails.resolutionStatus == VDFResolutionStatusFailed) {
            // resolution has finished
            // current session has finished, so clear it:
            self.currentResolveBuilder = nil;
            self.currentSessionToken = nil;
            self.currentDelegate = nil;
        }
        else {
            // we store session token for next use:
            self.currentSessionToken = userDetails.token;
        }
    }
    else if(error != nil) {
        // resolution has occured error, so clear curent session:
        self.currentResolveBuilder = nil;
        self.currentSessionToken = nil;
        self.currentDelegate = nil;
    }
}

- (void)didSMSPinRequested:(NSNumber*)isSuccess withError:(NSError*)error {}

- (void)didValidatedSMSToken:(VDFSmsValidationResponse*)response withError:(NSError*)error {}

@end

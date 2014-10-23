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
#import "VDFUserTokenDetails+Internal.h"
#import "VDFConfigurationManager.h"
#import "VDFStringHelper.h"

static dispatch_once_t * oneInstanceToken;

@interface VDFUsersService () <VDFUsersServiceDelegate>
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) NSString *currentSessionToken;
@property (nonatomic, strong) VDFUserResolveRequestBuilder *currentResolveBuilder;
@property (nonatomic, assign) id<VDFUsersServiceDelegate> currentDelegate;

- (void)retrieveUserDetailsOverHAP:(VDFUserResolveOptions*)options;
- (void)retrieveUserDetailsOverAPIX:(VDFUserResolveOptions*)options;
- (void)retrieveUserDetails:(VDFUserResolveOptions*)options;

#ifdef DEBUG
- (void)resetOneInstanceToken;
#endif

@end

@implementation VDFUsersService

+ (instancetype)sharedInstance {
    static VDFUsersService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    oneInstanceToken = &onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.diContainer = [VDFSettings globalDIContainer];
    });
    
    return sharedInstance;
}

#ifdef DEBUG
- (void)resetOneInstanceToken {
    // only for unit testing, reseting the singleton instance
    *oneInstanceToken = 0;
}
#endif

- (void)retrieveUserDetails:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    NSParameterAssert(options);
    NSParameterAssert(delegate);
    
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    NSParameterAssert(configuration.clientAppKey);
    NSParameterAssert(configuration.clientAppSecret);
    NSParameterAssert(configuration.backendAppKey);
    
    if(delegate != nil && self.currentSessionToken == nil && self.currentResolveBuilder == nil) {
        
        self.currentDelegate = delegate;
        if(options.msisdn == nil) {
            [self retrieveUserDetailsOverHAP:options];
        }
        else {
            [self retrieveUserDetailsOverAPIX:options];
        }
    }
}

- (void)sendSmsPin {
    
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    NSParameterAssert(configuration.clientAppKey);
    NSParameterAssert(configuration.clientAppSecret);
    NSParameterAssert(configuration.backendAppKey);
    
    if(self.currentSessionToken != nil && self.currentResolveBuilder != nil) {
        // create request object
        id builder = [[VDFSmsSendPinRequestBuilder alloc] initWithSessionToken:self.currentSessionToken diContainer:self.diContainer delegate:self.currentDelegate];
        id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
        [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
    }
    else {
        // return invalid input because we do not have started session
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        [self.currentDelegate didSMSPinRequested:@NO withError:error];
        self.currentDelegate = nil;
    }
}

- (void)validateSmsCode:(NSString*)smsCode {
    
    NSParameterAssert(smsCode);
    
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    NSParameterAssert(configuration.clientAppKey);
    NSParameterAssert(configuration.clientAppSecret);
    NSParameterAssert(configuration.backendAppKey);
    
    
    if(self.currentSessionToken == nil || self.currentResolveBuilder == nil
       || ![VDFStringHelper isStringValid:smsCode withRegularExpression:configuration.smsCodeValidationRegex]) {
        
        // return invalid input because we do not have started session or pin is invalid
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorInvalidInput userInfo:nil];
        [self.currentDelegate didSMSPinRequested:@NO withError:error];
    }
    else {
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
        [requestsManager cancelAllPendingRequests];
        
        self.currentDelegate = nil;
        self.currentResolveBuilder = nil;
        self.currentSessionToken = nil;
    }
}

#pragma mark -
#pragma mark - Private Implementation

- (void)retrieveUserDetailsOverHAP:(VDFUserResolveOptions*)options {
    // check potential HAP resolve error
    NSError *error = nil;
    VDFUserTokenDetails *errorUserDetails = nil;
    VDFDeviceUtility *deviceUtility = [self.diContainer resolveForClass:[VDFDeviceUtility class]];
    
    NSString *mccMnc = [deviceUtility simMccMnc];
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    if(mccMnc != nil) {
        if(![configuration.availableMccMnc containsObject:mccMnc]) {
            error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorOperatorNotSupported userInfo:nil];
        }
    }
    else {
        if([deviceUtility checkNetworkTypeAvailability] == VDFNetworkNotAvailable) {
            // in other case when mccMnc cannot be readed we are not connected to the GSM network so we can imidettly return error
            error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        }
        else {
            // no GSM connection so we cannot perform resolve
            errorUserDetails = [[VDFUserTokenDetails alloc] init];
            errorUserDetails.resolutionStatus = VDFResolutionStatusUnableToResolve;
        }
    }
    
    if(error != nil || errorUserDetails != nil) {
        // there is error so we cannot start the request
        [self.currentDelegate didReceivedUserDetails:errorUserDetails withError:error];
        self.currentDelegate = nil;
    }
    else {
        // we can move forward
        [self retrieveUserDetails:options];
    }
}

- (void)retrieveUserDetailsOverAPIX:(VDFUserResolveOptions*)options {
    
    NSError *error = nil;
    // msisdn is provided so we need to read market code from msisdn
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    VDFDeviceUtility *deviceUtility = [self.diContainer resolveForClass:[VDFDeviceUtility class]];
    
    options.market = [deviceUtility findMarketForMsisdn:options.msisdn inMarkets:configuration.availableMarkets];
    
    if(options.market == nil) {
        // this phone number is not available for user resolve
        error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorInvalidInput userInfo:nil];
    }
    else {
        // need to check msisdn validity
        NSString *marketCode = [NSString stringWithFormat:@"%@", [configuration.availableMarkets valueForKey:options.market]];
        
        // let's remove market code from msisdn
        NSString *phoneNumber = [options.msisdn stringByReplacingCharactersInRange:NSMakeRange(0, [marketCode length]) withString:[NSString string]];
        
        // validate the rest of msisdn
        if(![VDFStringHelper isStringValid:phoneNumber withRegularExpression:configuration.phoneNumberRegex]) {
            // the msisdn is not valid
            error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorInvalidInput userInfo:nil];
        }
    }
    
    if(error != nil) {
        // we have an error
        [self.currentDelegate didReceivedUserDetails:nil withError:error];
        self.currentDelegate = nil;
    }
    else {
        // we can move forward
        [self retrieveUserDetails:options];
    }
}

- (void)retrieveUserDetails:(VDFUserResolveOptions*)options {
    
    VDFUserResolveRequestBuilder *builder = [[VDFUserResolveRequestBuilder alloc] initWithOptions:options diContainer:self.diContainer delegate:self.currentDelegate];
    [[builder observersContainer] registerObserver:self withPriority:10]; // i neeed here some higher priority because service object need to be updated first
    self.currentResolveBuilder = builder;
    
    id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
    
    [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
    
    // on starting user resolve process we need to perform update of configuration
    VDFConfigurationManager *configurationManager = [self.diContainer resolveForClass:[VDFConfigurationManager class]];
    [configurationManager checkForUpdate];
}

#pragma mark -
#pragma mark - VDFUsersServiceDelegate Implementation

- (void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error {
    if(userDetails != nil) {
        if(userDetails.resolutionStatus == VDFResolutionStatusCompleted
           || userDetails.resolutionStatus == VDFResolutionStatusUnableToResolve) {
            // resolution has finished
            // current session has finished, so clear it:
            self.currentResolveBuilder = nil;
            self.currentSessionToken = nil;
            self.currentDelegate = nil;
        }
        else {
            // we store session token for next use:
            self.currentSessionToken = userDetails.tokenOfPendingResolution;
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

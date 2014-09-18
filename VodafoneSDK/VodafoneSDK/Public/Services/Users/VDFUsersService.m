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
    
    if(delegate != nil) {
        // create request object
        if(options == nil) {
            options = [[VDFUserResolveOptions alloc] init];
        }
        
        NSError *error = nil;
        if(options.msisdn == nil) {
            NSString *mccMnc = [VDFDeviceUtility simMccMnc];
            VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
            if(mccMnc != nil) {
                if(![configuration.availableMccMnc containsObject:mccMnc]) {
                    error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorOutOfVodafoneCellular userInfo:nil];
                }
            }
            else {
                error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoGSMConnection userInfo:nil];
            }
        }
        else {
            // msisdn is provided
            // we need to read market code from msisdn
            VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
            
            options.market = [VDFDeviceUtility findMarketForMsisdn:options.msisdn inMarkets:configuration.availableMarkets];
            
            if(options.market == nil) {
                // this phone number is not available for user resolve:
                error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorMsisdnCountryNotSupported userInfo:nil];
            }
        }
        
        if(error != nil) {
            // there is error so we cannot start the request
            [delegate didReceivedUserDetails:nil withError:error];
        }
        else {
            // everything looks fine, move forward
            
            id builder = [[VDFUserResolveRequestBuilder alloc] initWithOptions:options diContainer:self.diContainer delegate:delegate];
            
            id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
            
            [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
        }
    }
}

- (void)sendSmsPinInSession:(NSString*)sessionToken delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    if(delegate != nil) {
        // create request object
        if(sessionToken == nil) {
            sessionToken = [NSString string];
        }
        
        id builder = [[VDFSmsSendPinRequestBuilder alloc] initWithSessionToken:sessionToken diContainer:self.diContainer delegate:delegate];
        
        id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
        
        [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
    }
}

- (void)validateSmsCode:(NSString*)smsCode inSession:(NSString*)sessionToken delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    if(delegate != nil) {
        // create request object
        if(smsCode == nil) {
            smsCode = [NSString string];
        }
        if(sessionToken == nil) {
            sessionToken = [NSString string];
        }
        
        VDFSmsValidationRequestBuilder *builder = [[VDFSmsValidationRequestBuilder alloc] initWithSessionToken:sessionToken smsCode:smsCode diContainer:self.diContainer delegate:delegate];
        
        id builderWithOAuth = [[VDFRequestBuilderWithOAuth alloc] initWithBuilder:builder oAuthTokenSetSelector:@selector(setOAuthToken:)];
        
        [[self.diContainer resolveForClass:[VDFServiceRequestsManager class]] performRequestWithBuilder:builderWithOAuth];
    }
}

- (void)removeDelegate:(id<VDFUsersServiceDelegate>)delegate {
    
    if(delegate != nil) {
        // get http request manager
        VDFServiceRequestsManager * requestsManager = [self.diContainer resolveForClass:[VDFServiceRequestsManager class]];
        
        // inform about request remove
        [requestsManager removeRequestObserver:delegate];
    }
}

@end

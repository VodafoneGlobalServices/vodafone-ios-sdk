//
//  VDFConfigurationUpdate_Success_TestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 17/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"
#import "VDFSettings.h"
#import "VDFSettings+Internal.h"
#import "VDFDIContainer.h"
#import "VDFBaseConfiguration.h"
#import "VDFBaseConfiguration+Manager.h"

static NSInteger const VERIFY_DELAY = 8;

@interface VDFConfigurationUpdate_Success_TestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFConfigurationUpdate_Success_TestCase

- (void)setUp
{
//    [self stubRequest:[self filterUpdateConfigurationRequest] withResponsesList:@[[super responseUpdateConfiguration200WithMaxAge:1800]]];
    
    self.stubConfigUpdate = [NSNumber numberWithBool:NO];// we do not stub as default configuration update
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


// TODO create new base test case for integration tests

- (void)_test_IsPerformingHttpCall_WhenCacheControlSetMaxAge {

    // this cannot be tested because ohttpstubs stubs also http caching mechanism
    
}

- (void)test_isConfigurationUpdating_OnSDKInitialization {
    
    // mock DI container:
    id mockDIContainer = OCMPartialMock([VDFSettings globalDIContainer]);
    
    // stub only one response of configuration update
    [super stubRequest:[self filterUpdateConfigurationRequest] withResponsesList:@[[super responseUpdateConfiguration200WithMaxAge:1800]]];
    
    // expect that the new configuration will be propagated over di container:
    [[mockDIContainer expect] registerInstance:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(obj) {
            VDFBaseConfiguration *newConf = (VDFBaseConfiguration*)obj;
            
            return [newConf.hapHost isEqualToString:@"http_test://ihap-pre.sp.vodafone.com_test"]
            && [newConf.apixHost isEqualToString:@"https_test://apisit.developer.vodafone.com_test"]
            && [newConf.oAuthTokenUrlPath isEqualToString:@"/2/oauth/access-token_test"]
            && [newConf.oAuthTokenScope isEqualToString:@"seamless_id_resolve_test"]
            && [newConf.oAuthTokenGrantType isEqualToString:@"client_credentials_test"]
            && [newConf.serviceBasePath isEqualToString:@"/seamless-id/users/tokens_test"]
            && newConf.defaultHttpConnectionTimeout == 56
            && newConf.requestsThrottlingLimit == 23
            && newConf.requestsThrottlingPeriod == 45
            && [[newConf.availableMarkets allKeys] count] == 1 && [[newConf.availableMarkets valueForKey:@"PT_test"] intValue] == 123333
            && [newConf.phoneNumberRegex isEqualToString:@"^[0-9]{7,12}$_test"]
            && [newConf.availableMccMnc count] == 1 && [[newConf.availableMccMnc objectAtIndex:0] isEqualToString:@"26801_test"];
        }
        return NO;
    }] forClass:[VDFBaseConfiguration class]];
    
    // run
    [VDFSettings initialize];
    
    // verify
    [mockDIContainer verifyWithDelay:VERIFY_DELAY];
}

- (void)test_isConfigurationUpdating_OnUserResolve {
    
    // mock DI container:
    id mockDIContainer = OCMPartialMock([VDFSettings globalDIContainer]);
    
    // stub only one response of configuration update
    [super stubRequest:[self filterUpdateConfigurationRequest] withResponsesList:@[[super responseUpdateConfiguration200WithMaxAge:1800]]];
    
    // stub for o auth:
    [super stubRequest:[self filterOAuthRequest] withResponsesList:@[ [super responseOAuthSuccessExpireInSeconds:18000] ]];
    
    // stub for user resolve:
    [super stubRequest:[self filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve201] ]];
    
    // expect that the new configuration will be propagated over di container:
    [[mockDIContainer expect] registerInstance:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(obj) {
            VDFBaseConfiguration *newConf = (VDFBaseConfiguration*)obj;
            
            return [newConf.hapHost isEqualToString:@"http_test://ihap-pre.sp.vodafone.com_test"]
            && [newConf.apixHost isEqualToString:@"https_test://apisit.developer.vodafone.com_test"]
            && [newConf.oAuthTokenUrlPath isEqualToString:@"/2/oauth/access-token_test"]
            && [newConf.oAuthTokenScope isEqualToString:@"seamless_id_resolve_test"]
            && [newConf.oAuthTokenGrantType isEqualToString:@"client_credentials_test"]
            && [newConf.serviceBasePath isEqualToString:@"/seamless-id/users/tokens_test"]
            && newConf.defaultHttpConnectionTimeout == 56
            && newConf.requestsThrottlingLimit == 23
            && newConf.requestsThrottlingPeriod == 45
            && [[newConf.availableMarkets allKeys] count] == 1 && [[newConf.availableMarkets valueForKey:@"PT_test"] intValue] == 123333
            && [newConf.phoneNumberRegex isEqualToString:@"^[0-9]{7,12}$_test"]
            && [newConf.availableMccMnc count] == 1 && [[newConf.availableMccMnc objectAtIndex:0] isEqualToString:@"26801_test"];
        }
        return NO;
    }] forClass:[VDFBaseConfiguration class]];
    
    // run
    [self.serviceToTest retrieveUserDetails:[[VDFUserResolveOptions alloc] initWithMSISDN:@"49123123123"]
                                   delegate:self.mockDelegate];
    
    // verify
    [mockDIContainer verifyWithDelay:VERIFY_DELAY];
}

@end

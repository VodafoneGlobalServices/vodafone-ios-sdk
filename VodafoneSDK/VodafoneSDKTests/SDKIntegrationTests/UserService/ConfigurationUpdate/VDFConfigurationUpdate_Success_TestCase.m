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
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [super rejectAnyNotHandledHttpCall];
    
    // wait 2 seconds that the configuration will perform update in SDK initialization
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
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
    
    // stub only one response of configuration update
    [super stubRequest:[self filterUpdateConfigurationRequest] withResponsesList:@[[super responseUpdateConfiguration200WithMaxAge:1800]]];
    
    // run
    [VDFSettings initialize];
    
    // verify
    
    NSTimeInterval delay = VERIFY_DELAY;
    NSTimeInterval step = 0.1;
    BOOL isConfigurationUpdated = NO;
    
    // expect that the new configuration will be propagated over di container:
    while (delay > 0) {
        VDFBaseConfiguration *newConf = [[VDFSettings globalDIContainer] resolveForClass:[VDFBaseConfiguration class]];
        
        isConfigurationUpdated = [newConf.hapHost isEqualToString:@"https://ihap-pre.sp.vodafone.test.com"]
        && [newConf.apixHost isEqualToString:@"http://apisit.developer.vodafone.test.com"]
        && [newConf.oAuthTokenUrlPath isEqualToString:@"/test/2/oauth/access-token"]
        && [newConf.oAuthTokenScope isEqualToString:@"seamless_id_resolve_test"]
        && [newConf.oAuthTokenGrantType isEqualToString:@"client_credentials_test"]
        && [newConf.serviceBasePath isEqualToString:@"/test/seamless-id/users/tokens"]
        && newConf.defaultHttpConnectionTimeout == 56
        && newConf.requestsThrottlingLimit == 23
        && newConf.requestsThrottlingPeriod == 45
        && [[newConf.availableMarkets allKeys] count] == 1 && [[newConf.availableMarkets valueForKey:@"PT_test"] intValue] == 123333
        && [newConf.phoneNumberRegex isEqualToString:@"^[0-9]{7,12}$_test"]
        && [newConf.availableMccMnc count] == 1 && [[newConf.availableMccMnc objectAtIndex:0] isEqualToString:@"26801_test"];
        
        if(isConfigurationUpdated) {
            break;
        }
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:step]];
        delay -= step;
        step += 0.1;
    }
    
    XCTAssertTrue(isConfigurationUpdated, @"Configuration should update");
}

- (void)test_isConfigurationUpdating_OnUserResolve {
    
    // mock
    super.smsValidation = YES;
    
    // stub only one response of configuration update
    [super stubRequest:[self filterUpdateConfigurationRequest] withResponsesList:@[ [super responseUpdateConfiguration200WithMaxAge:1800]]];
    
    // stub for o auth:
    [super stubRequest:[self filterOAuthRequest] withResponsesList:@[ [super responseOAuthSuccessExpireInSeconds:18000] ]];
    
    // stub for user resolve:
    [super stubRequest:[self filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve201] ]];
    
    // run
    [super.serviceToTest retrieveUserDetails:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                    delegate:super.mockDelegate];
    
    // verify
    NSTimeInterval delay = VERIFY_DELAY;
    NSTimeInterval step = 0.1;
    BOOL isConfigurationUpdated = NO;
    
    // expect that the new configuration will be propagated over di container:
    while (delay > 0) {
        VDFBaseConfiguration *newConf = [[VDFSettings globalDIContainer] resolveForClass:[VDFBaseConfiguration class]];
        
        isConfigurationUpdated = [newConf.hapHost isEqualToString:@"https://ihap-pre.sp.vodafone.test.com"]
        && [newConf.apixHost isEqualToString:@"http://apisit.developer.vodafone.test.com"]
        && [newConf.oAuthTokenUrlPath isEqualToString:@"/test/2/oauth/access-token"]
        && [newConf.oAuthTokenScope isEqualToString:@"seamless_id_resolve_test"]
        && [newConf.oAuthTokenGrantType isEqualToString:@"client_credentials_test"]
        && [newConf.serviceBasePath isEqualToString:@"/test/seamless-id/users/tokens"]
        && newConf.defaultHttpConnectionTimeout == 56
        && newConf.requestsThrottlingLimit == 23
        && newConf.requestsThrottlingPeriod == 45
        && [[newConf.availableMarkets allKeys] count] == 1 && [[newConf.availableMarkets valueForKey:@"PT_test"] intValue] == 123333
        && [newConf.phoneNumberRegex isEqualToString:@"^[0-9]{7,12}$_test"]
        && [newConf.availableMccMnc count] == 1 && [[newConf.availableMccMnc objectAtIndex:0] isEqualToString:@"26801_test"];
        
        if(isConfigurationUpdated) {
            break;
        }
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:step]];
        delay -= step;
        step += 0.1;
    }
    
    XCTAssertTrue(isConfigurationUpdated, @"Configuration should update");
}

@end

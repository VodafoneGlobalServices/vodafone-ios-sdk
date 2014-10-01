//
//  VDFResolveWithSmsValidationTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 26/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUsersService.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUserTokenDetails.h"
#import "VDFSettings.h"
#import "VDFError.h"
#import "VDFSmsValidationResponse.h"

@interface VDFResolveWithSmsValidationTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFResolveWithSmsValidationTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_Resolution_AfterCheckStatus_NeedSmsValidationOnRequest_IsSuccessful {
    
    // mock
    super.smsValidation = YES;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - sms validation required
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterMs:100000]]];
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin request
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseValidatePin200]]];
    
    [super rejectAnyNotHandledHttpCall];
    
    // expect that the delegate object will be invoked correctly:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:YES];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    
    // verify
    [super.mockDelegate verifyWithDelay:10];
}



@end

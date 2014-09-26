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


- (void)test_Resolution_AfterCheckStatus_NeedSmsValidation_IsSuccessful {
    
    // mock
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterMs:1000]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 302 - need sms validation
    // 200 - ok
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [super responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [super responseCheckStatus302SmsRequiredAndRetryAfterMs:1000],
                         [super responseCheckStatus200]]];
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin request
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    [super rejectAnyOtherHttpCall];
    
    // expect that the delegate object will be invoked correctly:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    
    // verify
    [super.mockDelegate verifyWithDelay:12];
}

- (void)test_Resolution_AfterCheckStatus_NeedSmsValidationOnRequest_IsSuccessful {
    
    // mock
    super.smsValidation = YES;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterMs:1000]]];
    
    // stub check status response with sequence:
    // 302 - need sms validation
    // 200 - ok
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302SmsRequiredAndRetryAfterMs:1000],
                         [super responseCheckStatus200]]];
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin request
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    [super rejectAnyOtherHttpCall];
    
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

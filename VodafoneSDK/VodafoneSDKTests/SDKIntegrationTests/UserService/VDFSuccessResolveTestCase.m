//
//  VDFSuccessResolveTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 30/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFUsersServiceBaseTestCase.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>
#import "VDFUsersService.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUserTokenDetails.h"
#import "VDFSettings.h"
#import "VDFError.h"
#import "VDFSmsValidationResponse.h"

static NSInteger const VERIFY_DELAY = 8;

@interface VDFSuccessResolveTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFSuccessResolveTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // rejecting any not handled requests
    [super rejectAnyNotHandledHttpCall];
    
    // expect that the delegate object will be invoked with completed status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark -
#pragma mark - tests for ResolutionIsSuccessful_InFirstStep

- (void)performTestFor_ResolutionIsSuccessful_InFirstStep_WithOptions:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    super.msisdn = options.msisdn;
    // stub success resolve 201
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve201]]];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

- (void)test_ResolutionIsSuccessful_InFirstStep_WithSmsValidationSetToNO {
    [self performTestFor_ResolutionIsSuccessful_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolutionIsSuccessful_InFirstStep_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsSuccessful_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolutionIsSuccessful_InFirstStep_WithMSISDN {
    [self performTestFor_ResolutionIsSuccessful_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}


#pragma mark -
#pragma mark - tests for ResolutionIsSuccessful_AfterCheckStatus

- (void)performTestFor_ResolutionIsSuccessful_AfterCheckStatus_WithOptions:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    super.msisdn = options.msisdn;
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterMs:500]]]; // retry after half of second
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 200 - ok
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [super responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [super responseCheckStatus200]]];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}



- (void)test_ResolutionIsSuccessful_AfterCheckStatus_WithSmsValidationSetToNO {
    [self performTestFor_ResolutionIsSuccessful_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolutionIsSuccessful_AfterCheckStatus_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsSuccessful_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolutionIsSuccessful_AfterCheckStatus_WithMSISDN {
    [self performTestFor_ResolutionIsSuccessful_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}



#pragma mark -
#pragma mark - tests for ResolutionIsSuccessful_AfterCheckStatus_NeedSmsValidation

- (void)performTestFor_ResolutionIsSuccessful_AfterCheckStatus_NeedSMSValidation_WithOptions:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    super.msisdn = options.msisdn;
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterMs:500]]]; // retry after half of second
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 302 - need sms validation
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [super responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [super responseCheckStatus302SmsRequiredAndRetryAfterMs:1000]]];
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    // stub validate pin request
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseValidatePin200]]];
    
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsSuccessful_AfterCheckStatus_NeedSMSValidation_WithSmsValidationSetToNO {
    [self performTestFor_ResolutionIsSuccessful_AfterCheckStatus_NeedSMSValidation_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolutionIsSuccessful_AfterCheckStatus_NeedSMSValidation_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsSuccessful_AfterCheckStatus_NeedSMSValidation_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolutionIsSuccessful_AfterCheckStatus_NeedSMSValidation_WithMSISDN {
    [self performTestFor_ResolutionIsSuccessful_AfterCheckStatus_NeedSMSValidation_WithOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}





#pragma mark -
#pragma mark - tests for ResolutionIsSuccessful_NeedSmsValidation

- (void)performTestFor_ResolutionIsSuccessful_NeedSMSValidation_WithMSISDN:(NSString*)msisdn {
    // mock
    super.smsValidation = YES;
    VDFUserResolveOptions *options = nil;
    if(msisdn != nil) {
        super.msisdn = msisdn;
        options = [[VDFUserResolveOptions alloc] initWithMSISDN:msisdn];
    }
    else {
        options = [[VDFUserResolveOptions alloc] initWithSmsValidation:YES];
    }
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterMs:1000]]];
    
    // check status should be never be called in this case
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    // stub validate pin request
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseValidatePin200]]];
    
    // expect only one status, that the resolution status will be set to validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsSuccessful_NeedSMSValidation_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsSuccessful_NeedSMSValidation_WithMSISDN:nil];
}

- (void)test_ResolutionIsSuccessful_NeedSMSValidation_WithMSISDN {
    [self performTestFor_ResolutionIsSuccessful_NeedSMSValidation_WithMSISDN:super.msisdn];
}




@end

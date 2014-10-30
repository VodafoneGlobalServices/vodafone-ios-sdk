//
//  VDFFailedResolveTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

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

@interface VDFFailedResolveTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFFailedResolveTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // rejecting any not handled requests
    [super rejectAnyNotHandledHttpCall];
    
    // expect that the delegate object will be invoked with unable to resolve status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusUnableToResolve];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark -
#pragma mark - tests for ResolutionIsFailed_InFirstStep

- (void)performTestFor_ResolutionIsFailed_InFirstStep_WithOptions:(VDFUserResolveOptions*)options {
    
    // mock
    super.smsValidation = options.smsValidation;
    super.msisdn = options.msisdn;
    
    // stub resolve with 404 response
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseEmptyWithCode:404]]];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

- (void)test_ResolutionIsFailed_InFirstStep_WithSmsValidationSetToNO {
    [self performTestFor_ResolutionIsFailed_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolutionIsFailed_InFirstStep_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsFailed_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolutionIsFailed_InFirstStep_WithMSISDN {
    [self performTestFor_ResolutionIsFailed_InFirstStep_WithOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}



#pragma mark -
#pragma mark - tests for ResolutionIsFailed_AfterCheckStatus

- (void)performTestFor_ResolutionIsFailed_AfterCheckStatus_WithOptions:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    super.msisdn = options.msisdn;
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterDefaultMs]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 200 - ok
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterDefaultMs],
                         [super responseCheckStatus304NotModifiedAndRetryAfterDefaultMs],
                         [super responseEmptyWithCode:404]]];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}



- (void)test_ResolutionIsFailed_AfterCheckStatus_WithSmsValidationSetToNO {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolutionIsFailed_AfterCheckStatus_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolutionIsFailed_AfterCheckStatus_WithMSISDN {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_WithOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}



#pragma mark -
#pragma mark - tests for ResolutionIsFailed_AfterCheckStatus_InGeneratePIN

- (void)performTestFor_ResolutionIsFailed_AfterCheckStatus_InGeneratePIN_WithOptions:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    super.msisdn = options.msisdn;
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterDefaultMs]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 302 - need sms validation
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterDefaultMs],
                         [super responseCheckStatus304NotModifiedAndRetryAfterDefaultMs],
                         [super responseCheckStatus302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:404]]];
    
    
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidSMSPinRequestedWithErrorCode:VDFErrorResolutionTimeout];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsFailed_AfterCheckStatus_InGeneratePIN_WithSmsValidationSetToNO {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_InGeneratePIN_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolutionIsFailed_AfterCheckStatus_InGeneratePIN_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_InGeneratePIN_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolutionIsFailed_AfterCheckStatus_InGeneratePIN_WithMSISDN {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_InGeneratePIN_WithOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}






#pragma mark -
#pragma mark - tests for ResolutionIsFailed_AfterCheckStatus_InSMSValidate

- (void)performTestFor_ResolutionIsFailed_AfterCheckStatus_InSMSValidate_WithOptions:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    super.msisdn = options.msisdn;
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterDefaultMs]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 302 - need sms validation
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterDefaultMs],
                         [super responseCheckStatus304NotModifiedAndRetryAfterDefaultMs],
                         [super responseCheckStatus302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    // stub validate pin request
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseEmptyWithCode:404]]];
    
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    [super expectDidValidatedSMSWithErrorCode:VDFErrorResolutionTimeout];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsFailed_AfterCheckStatus_InSMSValidate_WithSmsValidationSetToNO {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_InSMSValidate_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolutionIsFailed_AfterCheckStatus_InSMSValidate_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_InSMSValidate_WithOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolutionIsFailed_AfterCheckStatus_InSMSValidate_WithMSISDN {
    [self performTestFor_ResolutionIsFailed_AfterCheckStatus_InSMSValidate_WithOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}




#pragma mark -
#pragma mark - tests for ResolutionIsFailed_InGeneratePIN_WithMSISDN

- (void)performTestFor_ResolutionIsFailed_InGeneratePIN_WithMSISDN:(NSString*)msisdn {
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
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // check status should be never be called in this case
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:404]]];
    
    // expect only one status, that the resolution status will be set to validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidSMSPinRequestedWithErrorCode:VDFErrorResolutionTimeout];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsFailed_InGeneratePIN_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsFailed_InGeneratePIN_WithMSISDN:nil];
}

- (void)test_ResolutionIsFailed_InGeneratePIN_WithMSISDN {
    [self performTestFor_ResolutionIsFailed_InGeneratePIN_WithMSISDN:super.msisdn];
}


#pragma mark -
#pragma mark - tests for ResolutionIsFailed_InValidatePIN_WithMSISDN

- (void)performTestFor_ResolutionIsFailed_InValidatePIN_WithMSISDN:(NSString*)msisdn {
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
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // check status should be never be called in this case
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    // stub validate pin request
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseEmptyWithCode:404]]];
    
    // expect only one status, that the resolution status will be set to validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    [super expectDidValidatedSMSWithErrorCode:VDFErrorResolutionTimeout];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsFailed_InValidatePIN_WithSmsValidationSetToYES {
    [self performTestFor_ResolutionIsFailed_InValidatePIN_WithMSISDN:nil];
}

- (void)test_ResolutionIsFailed_InValidatePIN_WithMSISDN {
    [self performTestFor_ResolutionIsFailed_InValidatePIN_WithMSISDN:super.msisdn];
}





@end

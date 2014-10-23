//
//  VDFValidatePin_ErrorHandling_TestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 14/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"

static NSInteger const VERIFY_DELAY = 3;

@interface VDFValidatePin_ErrorHandling_TestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFValidatePin_ErrorHandling_TestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // reject any unexpected response
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Testing error returned after first resolve response response

- (void)doTest_ForValidatePin_InFirst_ResolveResponse:(int)statusCode
                                            errorCode:(VDFErrorCode)errorCode
                                              options:(VDFUserResolveOptions*)options {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    
    // stub resolve with 302 - not finished
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302SmsRequiredAndRetryAfterMs:500] ]];
    
    // stub for generate pin
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub for validate pin
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseEmptyWithCode:statusCode]]];
    
    // expect that the delegate object will be invoked only with sms validation status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect generated pin success response:
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^() {
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    // expect that the delegate object will be invoked with error code:
    [super expectDidValidatedSMSWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
}

#pragma mark for 500 response

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithSmsValidationNO_500_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithSmsValidationYES_500_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithMSISDN_500_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}


#pragma mark for 400 response

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithSmsValidationNO_400_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithSmsValidationYES_400_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithMSISDN_400_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}

#pragma mark for 403 response

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithSmsValidationNO_403_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithSmsValidationYES_403_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ForValidatePin_InFirst_ResolveResponse_WithMSISDN_403_Error {
    [self doTest_ForValidatePin_InFirst_ResolveResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}




#pragma mark - Testing error returned after check status response response

- (void)doTest_ForValidatePin_InNextCheckStatusResponse:(int)statusCode
                                              errorCode:(VDFErrorCode)errorCode
                                                options:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    
    
    // stub resolve with 302 - not finished
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302NotFinishedAndRetryAfterMs:500] ]];
    
    // stub check status with 302 sms validation required
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:@[ [super responseCheckStatus302SmsRequiredAndRetryAfterMs:500] ]];
    
    // stub for generate pin
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub for validate pin
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseEmptyWithCode:statusCode]]];
    
    // expect that the delegate object will be invoked with sms validation status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect generated pin success response:
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^() {
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    // expect that the delegate object will be invoked with error code:
    [super expectDidValidatedSMSWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
}

#pragma mark for 500 response

- (void)test_ForSendPin_InNextCheckStatusResponse_WithSmsValidationNO_500_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ForSendPin_InNextCheckStatusResponse_WithSmsValidationYES_500_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ForSendPin_InNextCheckStatusResponse_WithMSISDN_500_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}


#pragma mark for 400 response

- (void)test_ForSendPin_InNextCheckStatusResponse_WithSmsValidationNO_400_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ForSendPin_InNextCheckStatusResponse_WithSmsValidationYES_400_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ForSendPin_InNextCheckStatusResponse_WithMSISDN_400_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}

#pragma mark for 403 response

- (void)test_ForSendPin_InNextCheckStatusResponse_WithSmsValidationNO_403_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ForSendPin_InNextCheckStatusResponse_WithSmsValidationYES_403_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ForSendPin_InNextCheckStatusResponse_WithMSISDN_403_Error {
    [self doTest_ForValidatePin_InNextCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}


@end

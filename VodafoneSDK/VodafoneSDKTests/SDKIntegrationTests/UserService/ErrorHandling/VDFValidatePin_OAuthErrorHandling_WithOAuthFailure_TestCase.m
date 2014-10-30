//
//  VDFValidatePin_OAuthErrorHandling_WithOAuthFailure_TestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 15/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"

static NSInteger const VERIFY_DELAY = 3;

@interface VDFValidatePin_OAuthErrorHandling_WithOAuthFailure_TestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFValidatePin_OAuthErrorHandling_WithOAuthFailure_TestCase

- (void)setUp
{
    [super setUp];
    
    // reject any unexpected response
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark -
#pragma mark - Testing oAuthError handling, when smsValidation came as first resolve response

- (void)doTest_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_ErrorResponse:(OHHTTPStubsResponseBlock)validatePinResponse
                                                       withOAuthSecondResponse:(OHHTTPStubsResponseBlock)oAuthSecondResponse
                                                                   withOptions:(VDFUserResolveOptions*)options
                                                            expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200], oAuthSecondResponse]];
    
    // stub retrieve user details with sms validation required
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302SmsRequiredAndRetryAfterDefaultMs] ]];
    
    // stub send sms pin response:
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate sms pin response with:
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[validatePinResponse]];
    
    // expect that the delegate object will be invoked with validation required status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect thath the delegate object will be invoked with successful send sms pin
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    // expect that the oAuthError will be returned
    [super expectDidValidatedSMSWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->OpCoNotValid->SuccessToken responses sequence

- (void)test_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                              expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                              expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithMSISDN {
    [self doTest_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                              expectedOAuthError:VDFErrorAuthorizationFailed];
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->ScopeNotValid->SuccessToken responses sequence

- (void)test_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                              expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                              expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithMSISDN {
    [self doTest_HandleValidatePin_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                              expectedOAuthError:VDFErrorAuthorizationFailed];
}


#pragma mark -
#pragma mark - Testing oAuthError handling, when smsValidation came from check status

- (void)doTest_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_ErrorResponse:(OHHTTPStubsResponseBlock)validatePinResponse
                                                      withOAuthSecondResponse:(OHHTTPStubsResponseBlock)oAuthSecondResponse
                                                                  withOptions:(VDFUserResolveOptions*)options
                                                           expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200], oAuthSecondResponse]];
    
    
    // stub retrieve user details with 302 - not finished
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302NotFinishedAndRetryAfterDefaultMs] ]];
    
    // stub first check status response with sms validation needed
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:@[ [super responseCheckStatus302SmsRequiredAndRetryAfterDefaultMs] ]];
    
    // stub send sms pin response:
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate sms pin response with:
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[validatePinResponse]];
    
    // expect that the delegate object will be invoked with validation required status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect thath the delegate object will be invoked with successful send sms pin
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    // expect that the oAuthError will be returned
    [super expectDidValidatedSMSWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->OpCoNotValid->SuccessToken responses sequence

- (void)test_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                             expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                             expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithMSISDN {
    [self doTest_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                             expectedOAuthError:VDFErrorAuthorizationFailed];
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->ScopeNotValid->SuccessToken responses sequence

- (void)test_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                             expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                             expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithMSISDN {
    [self doTest_HandleValidatePin_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                             expectedOAuthError:VDFErrorAuthorizationFailed];
}



@end

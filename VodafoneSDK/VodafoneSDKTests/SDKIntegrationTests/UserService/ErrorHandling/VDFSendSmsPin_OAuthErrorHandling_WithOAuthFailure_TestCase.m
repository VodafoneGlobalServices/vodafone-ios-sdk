//
//  VDFSendSmsPin_OAuthErrorHandling_WithOAuthFailure_TestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 09/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"

static NSInteger const VERIFY_DELAY = 2;

@interface VDFSendSmsPin_OAuthErrorHandling_WithOAuthFailure_TestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFSendSmsPin_OAuthErrorHandling_WithOAuthFailure_TestCase


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

- (void)doTest_HandleSendSms_AsFirstResolveResponse_OAuthFailure_ErrorResponse:(OHHTTPStubsResponseBlock)sendSmsPinResponse
                                                       withOAuthSecondResponse:(OHHTTPStubsResponseBlock)oAuthSecondResponse
                                                                   withOptions:(VDFUserResolveOptions*)options
                                                            expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200], oAuthSecondResponse]];
    
    // stub retrieve user details with sms validation required
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302SmsRequiredAndRetryAfterMs:500] ]];
    
    // stub send sms pin response with error:
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[sendSmsPinResponse]];
    
    // expect that the delegate object will be invoked with validation required status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect that the oAuthError will be returned
    [super expectDidSMSPinRequestedWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->OpCoNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                              expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                              expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                              expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->ScopeNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                              expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                              expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                         withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                     withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                              expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}


#pragma mark -
#pragma mark - Testing oAuthError handling, when smsValidation came from check status

- (void)doTest_HandleSendSms_AsCheckStatusResponse_OAuthFailure_ErrorResponse:(OHHTTPStubsResponseBlock)sendSmsPinResponse
                                                      withOAuthSecondResponse:(OHHTTPStubsResponseBlock)oAuthSecondResponse
                                                                  withOptions:(VDFUserResolveOptions*)options
                                                           expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200], oAuthSecondResponse]];
    
    
    // stub retrieve user details with 302 - not finished
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302NotFinishedAndRetryAfterMs:500] ]];
    
    // stub first check status response with sms validation needed
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:@[ [super responseCheckStatus302SmsRequiredAndRetryAfterMs:500] ]];
    
    // stub send sms pin response with error:
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[sendSmsPinResponse]];
    
    // expect that the pending status will be sent to the delegate object
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    
    // expect that the delegate object will be invoked with validation required status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect that the oAuthError will be returned
    [super expectDidSMSPinRequestedWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->OpCoNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                             expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                             expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_OpCoNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                             expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->ScopeNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                             expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                             expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuthFailure_Success_TokenExpired_ScopeNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsCheckStatusResponse_OAuthFailure_ErrorResponse:[super responseOAuthTokenExpired]
                                                        withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                                                    withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                             expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}



@end

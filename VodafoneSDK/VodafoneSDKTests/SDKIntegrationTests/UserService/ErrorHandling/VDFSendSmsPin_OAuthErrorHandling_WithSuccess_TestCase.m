//
//  VDFSendSmsPin_OAuthErrorHandling_TestCase.m
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

static NSInteger const VERIFY_DELAY = 3;

@interface VDFSendSmsPin_OAuthErrorHandling_WithSuccess_TestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFSendSmsPin_OAuthErrorHandling_WithSuccess_TestCase


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

- (void)doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:(NSArray*)oAuthResponsesList
                                                                withOptions:(VDFUserResolveOptions*)options
                                                         expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    NSArray *responsesList = errorCode < 0 ? @[[super responseOAuthSuccessExpireInSeconds:3200], [super responseOAuthSuccessExpireInSeconds:3200]] : @[[super responseOAuthSuccessExpireInSeconds:3200]];
    [super stubRequest:[super filterOAuthRequest] withResponsesList:responsesList];
    
    // stub resolve with 302 - sms validation required
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302SmsRequiredAndRetryAfterMs:500] ]];
    
    // stub send sms pin response with error:
    responsesList = oAuthResponsesList;
    if(errorCode < 0) {
        // if no error is expected, then at end we need to return success response
        responsesList = [responsesList arrayByAddingObject: [super responseEmptyWithCode:200]];
    }
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:responsesList];
    
    // expect that the delegate object will be invoked with sms validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    if(errorCode < 0) {
        // expect that the delegate object will be invoked next with sms validation status
        [super expectDidSMSPinRequestedWithSuccess:YES];
    }
    else {
        // expect that the oAuthError will be returned
        [super expectDidSMSPinRequestedWithErrorCode:errorCode];
    }
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}


#pragma mark - Testing oAuthError handling, when smsValidation came as first resolve response, for SuccessToken->TokenExpired->SuccessToken responses sequence

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_Expired_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                           expectedOAuthError:-1];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_Expired_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                           expectedOAuthError:-1];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_Expired_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                           expectedOAuthError:-1];
}



#pragma mark - Testing oAuthError handling, when smsValidation came as first resolve response, for SuccessToken->OpCoNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_OpCoNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}


#pragma mark - Testing oAuthError handling, when smsValidation came as first resolve response, for SuccessToken->ScopeNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsFirstResolveResponse_OAuth_Success_ScopeNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}



#pragma mark -
#pragma mark - Testing oAuthError handling, when smsValidation came from check status

- (void)doTest_HandleSendSms_AsCheckStatusResponse_WithOAuthErrorResponses:(NSArray*)oAuthResponsesList
                                                                withOptions:(VDFUserResolveOptions*)options
                                                         expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    NSArray *responsesList = errorCode < 0 ? @[[super responseOAuthSuccessExpireInSeconds:3200], [super responseOAuthSuccessExpireInSeconds:3200]] : @[[super responseOAuthSuccessExpireInSeconds:3200]];
    [super stubRequest:[super filterOAuthRequest] withResponsesList:responsesList];
    
    // stub resolve with 302 - not finished
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302NotFinishedAndRetryAfterMs:500] ]];
    
    // stub check status with 302 - sms validation required
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:@[ [super responseResolve302SmsRequiredAndRetryAfterMs:500] ]];
    
    // stub send sms pin response with error:
    responsesList = oAuthResponsesList;
    if(errorCode < 0) {
        // if no error is expected, then at end we need to return success response
        responsesList = [responsesList arrayByAddingObject: [super responseEmptyWithCode:200]];
    }
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:responsesList];
    
    // expect that the delegate object will be invoked with sms validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    
    if(errorCode < 0) {
        // expect that the delegate object will be invoked next with sms validation status
        [super expectDidSMSPinRequestedWithSuccess:YES];
    }
    else {
        // expect that the oAuthError will be returned
        [super expectDidSMSPinRequestedWithErrorCode:errorCode];
    }
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}


#pragma mark - Testing oAuthError handling, when smsValidation came from check status, for SuccessToken->TokenExpired->SuccessToken responses sequence

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_Expired_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                           expectedOAuthError:-1];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_Expired_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                           expectedOAuthError:-1];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_Expired_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                           expectedOAuthError:-1];
}



#pragma mark - Testing oAuthError handling, when smsValidation came from check status, for SuccessToken->OpCoNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_OpCoNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}


#pragma mark - Testing oAuthError handling, when smsValidation came from check status, for SuccessToken->ScopeNotValid->SuccessToken responses sequence

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}

- (void)test_HandleSendSms_AsCheckStatusResponse_OAuth_Success_ScopeNotValid_Success_WithMSISDN {
    [self doTest_HandleSendSms_AsFirstResolveResponse_WithOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                                                  withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                                                           expectedOAuthError:VDFErrorAuthorizationFailed];
}


@end

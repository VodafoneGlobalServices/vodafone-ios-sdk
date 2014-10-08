//
//  VDFCheckStatusOAuthErrorHandlingTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 08/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"

static NSInteger const VERIFY_DELAY = 3;

@interface VDFCheckStatusOAuthErrorHandlingTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFCheckStatusOAuthErrorHandlingTestCase

- (void)setUp
{
    [super setUp];
    // stub resolve with 302 - not finished
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302NotFinishedAndRetryAfterMs:500] ]];
    
    // reject any unexpected response
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)doTesOfCheckStatusOAuthErrorResponses:(NSArray*)oAuthResponsesList withOptions:(VDFUserResolveOptions*)options expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    NSArray *responsesList = errorCode < 0 ? @[[super responseOAuthSuccessExpireInSeconds:3200], [super responseOAuthSuccessExpireInSeconds:3200]] : @[[super responseOAuthSuccessExpireInSeconds:3200]];
    [super stubRequest:[super filterOAuthRequest] withResponsesList:responsesList];
    
    
    // stub check status response with error:
    responsesList = oAuthResponsesList;
    if(errorCode < 0) {
        responsesList = [responsesList arrayByAddingObject: [super responseCheckStatus302SmsRequiredAndRetryAfterMs:500]];
    }
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:responsesList];
    
    // expect that the delegate object will be invoked with pending status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    
    if(errorCode < 0) {
        // expect that the delegate object will be invoked next with sms validation status
        [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired];
    }
    else {
        // expect that the oAuthError will be returned
        [super expectDidReceivedUserDetailsWithErrorCode:errorCode];
    }
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->SuccessToken responses sequence

- (void)testCheckStatus_OAuth_Success_Expired_Success_WithSmsValidationNO {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                             expectedOAuthError:-1];
}

- (void)testCheckStatus_OAuth_Success_Expired_Success_WithSmsValidationYES {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                             expectedOAuthError:-1];
}

- (void)testCheckStatus_OAuth_Success_Expired_Success_WithMSISDN {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthTokenExpired]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                             expectedOAuthError:-1];
}



#pragma mark - Testing oAuthError handling for SuccessToken->OpCoNotValid->SuccessToken responses sequence

- (void)testCheckStatus_OAuth_Success_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                             expectedOAuthError:VDFErrorApixAuthorization];
}

- (void)testCheckStatus_OAuth_Success_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                             expectedOAuthError:VDFErrorApixAuthorization];
}

- (void)testCheckStatus_OAuth_Success_OpCoNotValid_Success_WithMSISDN {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthOpCoNotValidError]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                             expectedOAuthError:VDFErrorApixAuthorization];
}


#pragma mark - Testing oAuthError handling for SuccessToken->ScopeNotValid->SuccessToken responses sequence

- (void)testCheckStatus_OAuth_Success_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                             expectedOAuthError:VDFErrorApixAuthorization];
}

- (void)testCheckStatus_OAuth_Success_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                             expectedOAuthError:VDFErrorApixAuthorization];
}

- (void)testCheckStatus_OAuth_Success_ScopeNotValid_Success_WithMSISDN {
    [self doTesOfCheckStatusOAuthErrorResponses:@[[super responseOAuthScopeNotValidError]]
                                    withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                             expectedOAuthError:VDFErrorApixAuthorization];
}






- (void)doTesOfCheckStatusOAuthErrorResponse:(OHHTTPStubsResponseBlock)checkStatusResponse
                     withOAuthSecondResponse:(OHHTTPStubsResponseBlock)oAuthSecondResponse
                                 withOptions:(VDFUserResolveOptions*)options
                          expectedOAuthError:(VDFErrorCode)errorCode {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200], oAuthSecondResponse]];
    
    
    // stub check status response with error:
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:@[checkStatusResponse]];
    
    // expect that the delegate object will be invoked with pending status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    
    // expect that the oAuthError will be returned
    [super expectDidReceivedUserDetailsWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->OpCoNotValid->SuccessToken responses sequence

- (void)testCheckStatus_OAuth_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationNO {
    [self doTesOfCheckStatusOAuthErrorResponse:[super responseOAuthTokenExpired]
                       withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                   withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                            expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)testCheckStatus_OAuth_Success_TokenExpired_OpCoNotValid_Success_WithSmsValidationYES {
    [self doTesOfCheckStatusOAuthErrorResponse:[super responseOAuthTokenExpired]
                       withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                   withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                            expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)testCheckStatus_OAuth_Success_TokenExpired_OpCoNotValid_Success_WithMSISDN {
    [self doTesOfCheckStatusOAuthErrorResponse:[super responseOAuthTokenExpired]
                       withOAuthSecondResponse:[super responseOAuthOpCoNotValidError]
                                   withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                            expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}


#pragma mark - Testing oAuthError handling for SuccessToken->TokenExpired->ScopeNotValid->SuccessToken responses sequence

- (void)testCheckStatus_OAuth_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationNO {
    [self doTesOfCheckStatusOAuthErrorResponse:[super responseOAuthTokenExpired]
                       withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                   withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]
                            expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)testCheckStatus_OAuth_Success_TokenExpired_ScopeNotValid_Success_WithSmsValidationYES {
    [self doTesOfCheckStatusOAuthErrorResponse:[super responseOAuthTokenExpired]
                       withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                   withOptions:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]
                            expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}

- (void)testCheckStatus_OAuth_Success_TokenExpired_ScopeNotValid_Success_WithMSISDN {
    [self doTesOfCheckStatusOAuthErrorResponse:[super responseOAuthTokenExpired]
                       withOAuthSecondResponse:[super responseOAuthScopeNotValidError]
                                   withOptions:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]
                            expectedOAuthError:VDFErrorOAuthTokenRetrieval];
}




@end

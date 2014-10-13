//
//  VDFOAuthErrorHandlingTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"

static NSInteger const VERIFY_DELAY = 8;

@interface VDFOAuthErrorHandlingTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFOAuthErrorHandlingTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)test_Resolution_WithOAuthErrors {
    
    // mock
    super.smsValidation = NO;
    
    // stub http oauth in sequence like this:
    // 200 - with long expiration time (should be cached)
    // 403 - invalid scope,
    // 200 - with success but expired in 3 seconds,
    // 403 - opco not valid
    // 200 - with long expiration time (should be cached)
    [super stubRequest:[super filterOAuthRequest]
     withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:36000], [super responseOAuthScopeNotValidError],
                         [super responseOAuthSuccessExpireInSeconds:3], [super responseOAuthOpCoNotValidError],
                         [super responseOAuthSuccessExpireInSeconds:36000]]];
    
    // stub resolve in sequence like this: 403 - expired token, 201
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseOAuthTokenExpired], [super responseResolve201],
                         [super responseResolve201], [super responseResolve201]]];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // for 200 - with long expiration time (from oAuth)
    // 403 - expired token (from resolve) (here the erlier requested oAuthToken need to be removed from cache),
    // 403 - invalid scope (from oAuth) - after this secuence should be returned error VDFErrorAuthorizationFailed
    // because it take place when we try to download new oAuthToken
    [super expectDidReceivedUserDetailsWithErrorCode:VDFErrorAuthorizationFailed];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    
    // for 200 - with success but expired in 3 seconds (from oAuth) - this should be success
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // wait for 10 seconds to oAuthToken be expired
    [NSThread sleepForTimeInterval:10];
    
    // 403 - opco not valid (from oAuth) - after this secuence should be returned error VDFErrorAuthorizationFailed
    [super expectDidReceivedUserDetailsWithErrorCode:VDFErrorAuthorizationFailed];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // for 200 - with long expiration time (should be cached) - this should be success
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // this also should be success because oAuth token should be readed from internal cache
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
}


- (void)test_SuccessFullResolution_WithSmsValidation_WithVerifySmsOAuthError {
    
    // mock
    super.smsValidation = YES;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest]
     withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3600],
                         [super responseOAuthSuccessExpireInSeconds:36000]]];
    
    // stub resolve response with 302 - sms validation required
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterMs:100000]]];
    
    // stub send pin request
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin request
    // first with oAuthToken expiration
    // second with 200 OK
    [super stubRequest:[super filterValidatePinRequest]
     withResponsesList:@[[super responseOAuthTokenExpired],
                         [super responseValidatePin200]]];
    
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

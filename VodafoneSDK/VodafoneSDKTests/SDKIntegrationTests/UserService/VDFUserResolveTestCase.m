//
//  VDFUserResolveTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 22/09/14.
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

static NSInteger const VERIFY_DELAY = 5;

@interface VDFUserResolveTestCase : VDFUsersServiceBaseTestCase
@end

@implementation VDFUserResolveTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // mock
    
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)test_ResolutionIsSuccessful_InFirstStep {
    
    // mock
    self.smsValidation = NO;
    
    // stub http oauth
    [self stubRequest:[self filterOAuthRequest] withResponsesList:@[[self responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub success resolve 201
    [self stubRequest:[self filterResolveRequestWithSmsValidation] withResponsesList:@[[self responseResolve201]]];
    
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate];
    
    
    // verify
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsFailed_InFirstStep {
    
    // mock
    self.smsValidation = NO;
    
    // stub http oauth
    [self stubRequest:[self filterOAuthRequest] withResponsesList:@[[self responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub success resolve in sequence like this: 404, 500, 400, 401, 403
    [self stubRequest:[self filterResolveRequestWithSmsValidation]
     withResponsesList:@[[self responseEmptyWithCode:404], [self responseEmptyWithCode:500],
                         [self responseEmptyWithCode:400], [self responseEmptyWithCode:401],
                         [self responseEmptyWithCode:403]]];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusFailed]; // for 404
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
    
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication]; // for 500
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
    
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorInvalidInput]; // for 400
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify

    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication]; // for 401
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
    
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication]; // for 403
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}

- (void)test_Resolution_WithOAuthErrors {
    
    // mock
    self.smsValidation = NO;
    
    // stub http oauth in sequence like this:
    // 200 - with long expiration time (should be cached)
    // 403 - invalid scope,
    // 200 - with success but expired in 3 seconds,
    // 403 - opco not valid
    // 200 - with long expiration time (should be cached)
    // 403 - opco not valid (this response should not be called)
    [self stubRequest:[self filterOAuthRequest]
     withResponsesList:@[[self responseOAuthSuccessExpireInSeconds:36000], [self responseOAuthScopeNotValidError],
                         [self responseOAuthSuccessExpireInSeconds:3], [self responseOAuthOpCoNotValidError],
                         [self responseOAuthSuccessExpireInSeconds:36000], [self responseOAuthOpCoNotValidError]]];
    
    // stub resolve in sequence like this: 403 - expired token, 201
    [self stubRequest:[self filterResolveRequestWithSmsValidation]
     withResponsesList:@[[self responseOAuthTokenExpired], [self responseResolve201]]];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // for 200 - with long expiration time (from oAuth)
    // 403 - expired token (from resolve) (here the erlier requested oAuthToken need to be removed from cache),
    // 403 - invalid scope (from oAuth) - after this secuence should be returned error VDFErrorApixAuthorization
    // because it take place when we try to download new oAuthToken
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorOAuthTokenRetrieval];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    
    // for 200 - with success but expired in 3 seconds (from oAuth) - this should be success
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // wait for 5 seconds to oAuthToken be expired
    [NSThread sleepForTimeInterval:8];
    
    // 403 - opco not valid (from oAuth) - after this secuence should be returned error VDFErrorOAuthTokenRetrieval
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorOAuthTokenRetrieval];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // for 200 - with long expiration time (should be cached) - this should be success
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // this also should be success because oAuth token should be readed from internal cache
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate]; // run
    [self.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
}


- (void)test_Resolution_AfterCheckStatus_IsSuccessful {
    
    // mock
    self.smsValidation = NO;
    
    // stub http oauth
    [self stubRequest:[self filterOAuthRequest] withResponsesList:@[[self responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - not yet know sms validation
    [self stubRequest:[self filterResolveRequestWithSmsValidation] withResponsesList:@[[self responseResolve302NotFinishedAndRetryAfterMs:1000]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 200 - ok
    [self stubRequest:[self filterCheckStatusRequest]
     withResponsesList:@[[self responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [self responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [self responseCheckStatus200]]];
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate];
    
    
    // verify
    [self.mockDelegate verifyWithDelay:8];
}


- (void)test_Resolution_AfterCheckStatus_IsFailed {
    
    // mock
    self.smsValidation = NO;
    
    // stub http oauth
    [self stubRequest:[self filterOAuthRequest] withResponsesList:@[[self responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - not yet know sms validation
    [self stubRequest:[self filterResolveRequestWithSmsValidation] withResponsesList:@[[self responseResolve302NotFinishedAndRetryAfterMs:1000]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 400 - ok
    [self stubRequest:[self filterCheckStatusRequest]
     withResponsesList:@[[self responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [self responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [self responseEmptyWithCode:404]]];
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusFailed];
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate];
    
    // verify
    [self.mockDelegate verifyWithDelay:8];
}




- (void)test_Resolution_AfterCheckStatus_NeedSmsValidation_IsSuccessful {
    
    // mock
    self.smsValidation = NO;
    
    // stub http oauth
    [self stubRequest:[self filterOAuthRequest] withResponsesList:@[[self responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - not yet know sms validation
    [self stubRequest:[self filterResolveRequestWithSmsValidation] withResponsesList:@[[self responseResolve302NotFinishedAndRetryAfterMs:1000]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 302 - need sms validation
    // 200 - ok
    [self stubRequest:[self filterCheckStatusRequest]
     withResponsesList:@[[self responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [self responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [self responseCheckStatus302SmsRequiredAndRetryAfterMs:1000],
                         [self responseCheckStatus200]]];
    
    // stub send pin request
    [self stubRequest:[self filterGeneratePinRequest] withResponsesList:@[[self responseEmptyWithCode:200]]];
    
    // stub validate pin request
    [self stubRequest:[self filterValidatePinRequest] withResponsesList:@[[self responseEmptyWithCode:200]]];
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [self.serviceToTest sendSmsPin];
    }];
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    [self expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [self.serviceToTest validateSmsCode:self.smsCode];
    }];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate];
    
    
    // verify
    [self.mockDelegate verifyWithDelay:8];
}



@end

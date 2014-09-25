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
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub success resolve 201
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve201]]];
    
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_ResolutionIsFailed_InFirstStep {
    
    // mock
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub success resolve in sequence like this: 404, 500, 400, 401, 403
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseEmptyWithCode:404], [super responseEmptyWithCode:500],
                         [super responseEmptyWithCode:400], [super responseEmptyWithCode:401],
                         [super responseEmptyWithCode:403]]];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusFailed]; // for 404
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
    
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication]; // for 500
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
    
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorInvalidInput]; // for 400
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify

    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication]; // for 401
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
    
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication]; // for 403
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
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
    // 403 - opco not valid (this response should not be called)
    [super stubRequest:[super filterOAuthRequest]
     withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:36000], [super responseOAuthScopeNotValidError],
                         [super responseOAuthSuccessExpireInSeconds:3], [super responseOAuthOpCoNotValidError],
                         [super responseOAuthSuccessExpireInSeconds:36000], [super responseOAuthOpCoNotValidError]]];
    
    // stub resolve in sequence like this: 403 - expired token, 201
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseOAuthTokenExpired], [super responseResolve201]]];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // for 200 - with long expiration time (from oAuth)
    // 403 - expired token (from resolve) (here the erlier requested oAuthToken need to be removed from cache),
    // 403 - invalid scope (from oAuth) - after this secuence should be returned error VDFErrorApixAuthorization
    // because it take place when we try to download new oAuthToken
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorOAuthTokenRetrieval];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    
    // for 200 - with success but expired in 3 seconds (from oAuth) - this should be success
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // wait for 5 seconds to oAuthToken be expired
    [NSThread sleepForTimeInterval:8];
    
    // 403 - opco not valid (from oAuth) - after this secuence should be returned error VDFErrorOAuthTokenRetrieval
    [self expectDidReceivedUserDetailsWithErrorCode:VDFErrorOAuthTokenRetrieval];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // for 200 - with long expiration time (should be cached) - this should be success
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
    
    // this also should be success because oAuth token should be readed from internal cache
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];  // verify
}


- (void)test_Resolution_AfterCheckStatus_IsSuccessful {
    
    // mock
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterMs:1000]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 200 - ok
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [super responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [super responseCheckStatus200]]];
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    
    // verify
    [super.mockDelegate verifyWithDelay:8];
}


- (void)test_Resolution_AfterCheckStatus_IsFailed {
    
    // mock
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve response with 302 - not yet know sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve302NotFinishedAndRetryAfterMs:1000]]];
    
    // stub check status response with sequence:
    // 302 - not finished
    // 304 - not modified
    // 400 - ok
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [super responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [super responseEmptyWithCode:404]]];
    
    // expect that the delegate object will be invoked correctly:
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusPending];
    [self expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusFailed];
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:8];
}





/*
 - (void)testWhenResolutionFailedInFirstStep {}
 
 - (void)testWhenResolutionGetGenericServerError {}
 
 - (void)testWhenRequestHasNotPassedInputValdiation {}
 
 - (void)testWhenRequestIsNotAuthorizedAtApixButNotExpiredToken {}
 
 - (void)testWhenRequestIsNotAuthotizedAtApixButTokenExpired {}

 */


#pragma mark -
#pragma mark - helper methods
//- (void)doTestingOn


#pragma mark -
#pragma mark - expect methods
- (void)expectDidReceivedUserDetailsWithErrorCode:(VDFErrorCode)errorCode {
    
    [[self.mockDelegate expect] didReceivedUserDetails:nil withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        return [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
    }]];
}
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus {
    
    [[self.mockDelegate expect] didReceivedUserDetails:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFUserTokenDetails *tokenDetails = (VDFUserTokenDetails*)obj;
        
        if(tokenDetails.resolutionStatus != resolutionStatus) {
            return NO;
        }
        
        if(resolutionStatus == VDFResolutionStatusCompleted) {
            return [tokenDetails.token isEqualToString:super.sessionToken]
            && [tokenDetails.acr isEqualToString:super.acr]
            && tokenDetails.expiresIn != nil;
        }
        else if(resolutionStatus == VDFResolutionStatusFailed) {
            return tokenDetails.token == nil
            && tokenDetails.acr == nil
            && tokenDetails.expiresIn == nil;
        }
        else {
            return [tokenDetails.token isEqualToString:super.sessionToken] // TODO if we get know that this should not be returned to the 3rd party app in this case
            && tokenDetails.acr == nil
            && tokenDetails.expiresIn == nil;
        }
        
    }] withError:[OCMArg isNil]];
}

- (void)expectDidSMSPinRequestedWithSuccess:(BOOL)isSuccess {
    [[self.mockDelegate expect] didSMSPinRequested:[NSNumber numberWithBool:isSuccess] withError:[OCMArg isNil]];
}

- (void)expectDidSMSPinRequestedWithErrorCode:(VDFErrorCode)errorCode {
    [[self.mockDelegate expect] didSMSPinRequested:nil withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        return [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
    }]];
}

- (void)expectDidValidatedSMSWithSuccess:(BOOL)isSuccess {
    [[self.mockDelegate expect] didValidatedSMSToken:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFSmsValidationResponse *response = (VDFSmsValidationResponse*)obj;
        return [response.smsCode isEqualToString:super.smsCode] && response.isSucceded == isSuccess;
        
    }] withError:[OCMArg isNil]];
}

- (void)expectDidValidatedSMSWithErrorCode:(VDFErrorCode)errorCode {
    [[self.mockDelegate expect] didValidatedSMSToken:nil withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        return [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
    }]];
}

@end

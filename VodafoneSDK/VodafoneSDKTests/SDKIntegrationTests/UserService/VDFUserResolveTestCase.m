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

static NSInteger const VERIFY_DELAY = 3;

@interface VDFUsersService ()
- (NSError*)checkPotentialHAPResolveError;
- (NSError*)updateResolveOptionsAndCheckMSISDNForError:(VDFUserResolveOptions*)options;
@end

@interface VDFUserResolveTestCase : VDFUsersServiceBaseTestCase
@property id serviceToTest;
@property id mockDelegate;
@end

@implementation VDFUserResolveTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // mock
    self.serviceToTest = OCMPartialMock([VDFUsersService sharedInstance]);
    self.mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.serviceToTest stopMocking];
}



- (void)test_ResolutionIsSuccessful_InFirstStep_With {
    
    // mock
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub success resolve 201
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseResolve201]]];
    
    // stub the sim card checking
    [[[self.serviceToTest stub] andReturn:nil] checkPotentialHAPResolveError];
    
    
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
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub success resolve in sequence like this: 404, 500, 400, 401, 403
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseEmpty404], [super responseEmpty500],
                         [super responseEmpty400], [super responseEmpty401],
                         [super responseEmpty403]]];
    
    // stub the sim card checking
    [[[self.serviceToTest stub] andReturn:nil] checkPotentialHAPResolveError];
    
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

//
//  VDFUsersServiceIncorrectMethodCallSequenceTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 03/11/14.
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
#import "VDFBaseConfiguration.h"
#import "VDFDIContainer.h"
#import "VDFSettings+Internal.h"

static NSInteger const VERIFY_DELAY = 8;


@interface VDFUsersServiceIncorrectMethodCallSequenceTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFUsersServiceIncorrectMethodCallSequenceTestCase

- (void)setUp
{
    [super setUp];
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // rejecting any not handled requests
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)test_sendSMSPin_beforeFirstResolutionResponse {
    
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub resolve with success but with long response time
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseValidatePin200]]
           requestTime:0.2
          responseTime:0.2];
    
    // expect that the delegate object will be invoked with completed status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    // expect generate pin with invalid input
    [super expectDidSMSPinRequestedWithErrorCode:VDFErrorInvalidInput];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    [super.serviceToTest sendSmsPin]; // immidetly try to send a pin
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

- (void)test_validatePin_beforeFirstResolutionResponse {
    
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub resolve with success but with long response time
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseValidatePin200]]
           requestTime:0.2
          responseTime:0.2];
    
    // expect that the delegate object will be invoked with completed status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    // expect generate pin with invalid input
    [super expectDidValidatedSMSWithErrorCode:VDFErrorInvalidInput];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    [super.serviceToTest validateSmsCode:super.smsCode]; // immidetly try to validate a pin
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


@end

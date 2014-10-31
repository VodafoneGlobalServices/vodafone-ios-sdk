//
//  VDFManySameCallsStressTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/10/14.
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


@interface VDFManySameCallsStressTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFManySameCallsStressTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
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

- (void)test_stress_manyResolveCalls_onlyOneResolvePending {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub success resolve 201
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseResolve201]]
           requestTime:1
          responseTime:0.5];
    
    // expect that the delegate object will be invoked with completed status
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_stress_manySendSmsPin_onlyOneHTTPCallIsPending {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    VDFBaseConfiguration *configuration = [[VDFSettings globalDIContainer] resolveForClass:[VDFBaseConfiguration class]];
    configuration.requestsThrottlingLimit = 200;
    configuration.requestsThrottlingPeriod = 0.000001; // very short
    
    // stub resolve with 302 need sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // stub generate pin with success
    [super stubRequest:[super filterGeneratePinRequest]
     withResponsesList:@[[super responseEmptyWithCode:200]]
           requestTime:1
          responseTime:1];
    
    // expect that the delegate object will be invoked with validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        NSDate *startDate = [NSDate date];
        while([startDate timeIntervalSinceNow] > -1) { // stop if longer than one second
            [super.serviceToTest sendSmsPin];
        }
    }];
    
    // expect one generation of pin
    [super expectDidSMSPinRequestedWithSuccess:YES];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


- (void)test_stress_manyValidateSmsPin_onlyOneHTTPCallIsPendingPerSmsCode {
    
    // mock
    NSString *otherInvalidSmsCode = @"9988";
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    VDFBaseConfiguration *configuration = [[VDFSettings globalDIContainer] resolveForClass:[VDFBaseConfiguration class]];
    configuration.requestsThrottlingLimit = 200;
    configuration.requestsThrottlingPeriod = 0.000001; // very short
    
    // stub resolve with 302 need sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // stub generate pin with success
    [super stubRequest:[super filterGeneratePinRequest]
     withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin with success
    [super stubRequest:[super filterValidatePinRequest]
     withResponsesList:@[[super responseValidatePin200]]
           requestTime:1
          responseTime:1];
    
    // stub validate pin with invalid code
    [super stubRequest:[super filterValidatePinRequestWithCode:otherInvalidSmsCode]
     withResponsesList:@[[super responseEmptyWithCode:409]]
           requestTime:1
          responseTime:1];
    
    // expect that the delegate object will be invoked with validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    // expect one generation of pin
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        NSDate *startDate = [NSDate date];
        // with valid sms code:
        while([startDate timeIntervalSinceNow] > -0.5) { // stop if longer than one half of second
            [super.serviceToTest validateSmsCode:super.smsCode];
        }
        
        startDate = [NSDate date];
        // with invalid sms code:
        while([startDate timeIntervalSinceNow] > -0.5) { // stop if longer than one half of second
            [super.serviceToTest validateSmsCode:otherInvalidSmsCode];
        }
        
        
        startDate = [NSDate date];
        int i = 0;
        // with invalid sms code:
        while([startDate timeIntervalSinceNow] > -0.5) { // stop if longer than one half of second
            i = (i+1)%2;
            if(i == 0) {
                [super.serviceToTest validateSmsCode:super.smsCode];
            }
            else {
                [super.serviceToTest validateSmsCode:otherInvalidSmsCode];
            }
        }
    }];
    
    // expect validate pin success
    [super expectDidValidatedSMSWithSuccess];
    
    // expect also validate pin with invalid sms code:
    [super expectDidValidatedSMSCode:otherInvalidSmsCode withErrorCode:VDFErrorWrongSmsCode];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

@end

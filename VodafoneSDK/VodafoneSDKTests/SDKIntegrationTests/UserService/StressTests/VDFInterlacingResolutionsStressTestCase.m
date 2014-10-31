//
//  VDFInvalidCallsDuringResolveStressTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 31/10/14.
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



@interface VDFInterlacingResolutionsStressTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFInterlacingResolutionsStressTestCase

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


- (void)test_afterFirstSuccessResolutionWithSmsValidation_arrivesResponseOfInvalidSmsCode {
    
    /*
     Test scenario:
     
     Resolve -> Need sms validation (returned immidetly)
     Generate PIN -> OK (returned immidetly)
     ValidatePIN (valid code) -> OK (returned after next ValidatePIN call)
     ValidatePIN (invalid code) -> Failure (returned after last resolution is completed
     
     After last resolution process:
     <- arriving response of "ValidatePIN (invalid code)"
     */
    
    // mock
    NSString *otherInvalidSmsCode = @"9988";
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub resolve with 302 need sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // stub generate pin with success
    [super stubRequest:[super filterGeneratePinRequest]
     withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin with success
    [super stubRequest:[super filterValidatePinRequest]
     withResponsesList:@[[super responseValidatePin200]]
           requestTime:0.2
          responseTime:0.2];
    
    // stub validate pin with invalid code
    [super stubRequest:[super filterValidatePinRequestWithCode:otherInvalidSmsCode]
     withResponsesList:@[[super responseEmptyWithCode:409]]
           requestTime:0.5
          responseTime:0.2];
    
    // expect that the delegate object will be invoked with validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    // expect one generation of pin
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
        [super.serviceToTest validateSmsCode:otherInvalidSmsCode];
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


- (void)test_firstSuccessValidateSmsCode_andSecondResponseOfValidateSmsCodeArriveDuringNextRetrieveProcess {
    
    /*
     Test scenario:
     
     Resolve -> Need sms validation (returned immidetly)
     Generate PIN -> OK (returned immidetly)
     ValidatePIN (valid code) -> OK (returned after next ValidatePIN call)
     ValidatePIN (valid code) -> Failure (returned after last resolution is completed and next one is started)
     
     After last resolution process completed:
     Resolve -> Need sms validation (returned immidetly)
     <- arriving response of "ValidatePIN (invalid code)"
     */
    
    // mock
    NSString *otherValidSmsCode = @"9988";
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub resolve with 302 need sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterDefaultMs],
                         [super responseResolve302SmsRequiredAndRetryAfterDefaultMs]]];
    
    // stub generate pin with success
    [super stubRequest:[super filterGeneratePinRequest]
     withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin with success
    [super stubRequest:[super filterValidatePinRequest]
     withResponsesList:@[[super responseValidatePin200]]
           requestTime:0.2
          responseTime:0.2];
    
    // stub validate pin with invalid code
    [super stubRequest:[super filterValidatePinRequestWithCode:otherValidSmsCode]
     withResponsesList:@[[super responseValidatePin200]]
           requestTime:0.5
          responseTime:0.2];
    
    // for the first resolve process
    // expect that the delegate object will be invoked with validation required
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted onSuccessExecution:^(VDFUserTokenDetails *details) {
        super.sessionToken = @"someOtherSessionToken"; // we need to change session token of next request
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // starting next request after this response
        });
    }];
    
    // expect one generation of pin
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
        [super.serviceToTest validateSmsCode:otherValidSmsCode];
    }];
    
    // expect validate pin success
    [super expectDidValidatedSMSWithSuccess];
    // expect also validate pin with second sms code:
    [super expectDidValidatedSuccessfulSMSCode:otherValidSmsCode];
    
    
    // for the second resolution process we need only the validation required status:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


@end

//
//  VDFSlowConnectionStressTestCase.m
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

@interface VDFNetworkStressTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFNetworkStressTestCase

- (void)setUp
{
    [super setUp];
    
    // rejecting any not handled requests
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (OHHTTPStubsResponseBlock)responseWithConnectionError {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                          code:kCFURLErrorNotConnectedToInternet
                                                                      userInfo:nil]];
    };
}

- (void)test_networkDown_whileOAuthRetrieve_willNextResolutionCanBeStarted {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub http oauth with internet error
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[self responseWithConnectionError], [super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve request with Sms validation with success response
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve201] ]];
    
    // expect that the delegate object will be invoked with Authorization error
    [super expectDidReceivedUserDetailsWithErrorCode:VDFErrorAuthorizationFailed onMatchingExecution:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // check will SDK be available to make another resolution process
            [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
        });
    }];
    
    // expect that SDK will be available to make another resolution process
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

- (void)test_networkDown_whileFirstResolutionStep_willNextResolutionCanBeStarted {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve with internet connection error and next success response
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [self responseWithConnectionError], [super responseResolve201] ]];
    
    // expect that the delegate object will be invoked with server communication error
    [super expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication onMatchingExecution:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // check will SDK be available to make another resolution process
            [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
        });
    }];
    
    // expect that SDK will be available to make another resolution process
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

- (void)test_networkDown_whileCheckStatus_willNextResolutionCanBeStarted {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve - first with Need retry, second with success
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[ [super responseResolve302NotFinishedAndRetryAfterDefaultMs], [super responseResolve201] ]];
    
    // stub check status with some responses and internet connection error
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[ [super responseCheckStatus304NotModifiedAndRetryAfterDefaultMs], [self responseWithConnectionError] ]];
    
    // expect that the delegate object will be invoked with server communication error
    [super expectDidReceivedUserDetailsWithErrorCode:VDFErrorServerCommunication onMatchingExecution:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // check will SDK be available to make another resolution process
            [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
        });
    }];
    
    // expect that SDK will be available to make another resolution process
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

- (void)test_networkDown_whileGeneratePIN_willNextResolutionCanBeStarted {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve - first with Validation required, second with success
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[ [super responseResolve302SmsRequiredAndRetryAfterDefaultMs], [super responseResolve201] ]];
    
    // stub generatePIN with internet connection error
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[ [self responseWithConnectionError] ]];
    
    // expect that the validation will be required:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect generate pin with server communication error
    [super expectDidSMSPinRequestedWithErrorCode:VDFErrorServerCommunication onSuccessExecution:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // check will SDK be available to make another resolution process
            [super.serviceToTest cancelRetrieveUserDetails];
            [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
        });
    }];
    
    // expect that SDK will be available to make another resolution process
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

- (void)test_networkDown_whileValidatePIN_willNextResolutionCanBeStarted {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve - first with Validation required, second with success
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[ [super responseResolve302SmsRequiredAndRetryAfterDefaultMs], [super responseResolve201] ]];
    
    // stub generatePIN with success result
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[ [self responseEmptyWithCode:200] ]];
    
    // stub validatePIN with internet connection error
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[ [self responseWithConnectionError] ]];
    
    // expect that the validation will be required:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusValidationRequired onSuccessExecution:^(VDFUserTokenDetails *details) {
        [super.serviceToTest sendSmsPin];
    }];
    
    // expect success generation of the pin
    [super expectDidSMSPinRequestedWithSuccess:YES onSuccessExecution:^{
        [super.serviceToTest validateSmsCode:super.smsCode];
    }];
    
    // expect validate pin with server communication error
    [super expectDidValidatedSMSCode:super.smsCode withErrorCode:VDFErrorServerCommunication onSuccessExecution:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // check will SDK be available to make another resolution process
            [super.serviceToTest cancelRetrieveUserDetails];
            [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
        });
    }];
    
    // expect that SDK will be available to make another resolution process
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
    
    
    [super rejectAnyOtherDelegateCall];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}

@end

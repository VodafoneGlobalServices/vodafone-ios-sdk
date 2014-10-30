//
//  VDFCallsFromDifferentThreadsStressTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 30/10/14.
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
static NSInteger const DEFAULT_RETRY_AFTER_MS = 250; // in miliseconds

@interface VDFMockServiceDelegate : NSObject <VDFUsersServiceDelegate>
@property (nonatomic, weak) VDFUsersService *serviceToRespond;
@property NSString *smsCode;
@property BOOL didReceivedUserDetailsCompleted;
@property BOOL isDidReceivedUserDetailsOnMainThread;
@property BOOL isDidSMSPinRequestedOnMainThread;
@property BOOL isDidValidatedSMSTokenOnMainThread;
@end

@implementation VDFMockServiceDelegate
- (instancetype)init {
    self = [super init];
    if(self) {
        self.didReceivedUserDetailsCompleted = NO;
        self.isDidReceivedUserDetailsOnMainThread = NO;
        self.isDidSMSPinRequestedOnMainThread = NO;
        self.isDidValidatedSMSTokenOnMainThread = NO;
    }
    return self;
}

- (void)didReceivedUserDetails:(VDFUserTokenDetails *)userDetails withError:(NSError *)error {
    self.isDidReceivedUserDetailsOnMainThread = [NSThread isMainThread];
    self.didReceivedUserDetailsCompleted = userDetails.resolutionStatus == VDFResolutionStatusCompleted;
    
    if(userDetails.resolutionStatus == VDFResolutionStatusValidationRequired) {
        [self.serviceToRespond sendSmsPin];
    }
}

- (void)didSMSPinRequested:(NSNumber *)isSuccess withError:(NSError *)error {
    self.isDidSMSPinRequestedOnMainThread = [NSThread isMainThread];
    [self.serviceToRespond validateSmsCode:self.smsCode];
}

- (void)didValidatedSMSToken:(VDFSmsValidationResponse *)response withError:(NSError *)error {
    self.isDidValidatedSMSTokenOnMainThread = [NSThread isMainThread];
}
@end



@interface VDFCallsFromDifferentThreadsStressTestCase : VDFUsersServiceBaseTestCase
@property VDFMockServiceDelegate *serviceMockDelegate;
@end

@implementation VDFCallsFromDifferentThreadsStressTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.serviceMockDelegate = [[VDFMockServiceDelegate alloc] init];
    self.serviceMockDelegate.serviceToRespond = super.serviceToTest;
    self.serviceMockDelegate.smsCode = super.smsCode;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve with 302 need sms validation
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseResolve302SmsRequiredAndRetryAfterMs:DEFAULT_RETRY_AFTER_MS]]];
    
    // stub generate pin with success
    [super stubRequest:[super filterGeneratePinRequest] withResponsesList:@[[super responseEmptyWithCode:200]]];
    
    // stub validate pin with success
    [super stubRequest:[super filterValidatePinRequest] withResponsesList:@[[super responseValidatePin200]]];
    
    // rejecting any not handled requests
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    self.serviceMockDelegate.serviceToRespond = nil;
    self.serviceMockDelegate.smsCode = nil;
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)assertItsAllDelegateMethodsWasCAlledOnMainThreadWithDelay:(NSTimeInterval)delay {
    NSTimeInterval step = 0.1;
    while (delay > 0 && !self.serviceMockDelegate.didReceivedUserDetailsCompleted) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:step]];
        delay -= step;
        step += 0.1;
    }
    XCTAssertTrue(self.serviceMockDelegate.isDidReceivedUserDetailsOnMainThread, @"DidReceivedUserDetailsOnMainThread should return to main thread.");
    XCTAssertTrue(self.serviceMockDelegate.isDidSMSPinRequestedOnMainThread, @"DidSMSPinRequestedOnMainThread should return to main thread.");
    XCTAssertTrue(self.serviceMockDelegate.isDidValidatedSMSTokenOnMainThread, @"DidValidatedSMSTokenOnMainThread should return to main thread.");
}

- (void)testRetrieve_FromMainThread_RespondsToMainThread {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // run
    dispatch_async(dispatch_get_main_queue(), ^{
        [super.serviceToTest retrieveUserDetails:options delegate:self.serviceMockDelegate];
    });
    
    // assert:
    [self assertItsAllDelegateMethodsWasCAlledOnMainThreadWithDelay:VERIFY_DELAY];
}

- (void)testRetrieve_FromDifferentThread_RespondsToMainThread {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    
    // run
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [super.serviceToTest retrieveUserDetails:options delegate:self.serviceMockDelegate];
    });
    
    // assert:
    [self assertItsAllDelegateMethodsWasCAlledOnMainThreadWithDelay:VERIFY_DELAY];
}

@end

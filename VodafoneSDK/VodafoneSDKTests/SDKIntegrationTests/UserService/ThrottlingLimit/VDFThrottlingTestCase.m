//
//  VDFThrottlingTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 28/10/14.
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
#import "VDFSettings+Internal.h"
#import "VDFError.h"
#import "VDFSmsValidationResponse.h"
#import "VDFDIContainer.h"
#import "VDFBaseConfiguration.h"

static NSInteger const VERIFY_DELAY = 8;

@interface VDFThrottlingTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFThrottlingTestCase

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

#pragma mark -
#pragma mark - tests for ResolutionIsSuccessful_InFirstStep

- (void)test_retrieveUserDetails_willThrottlingLimitExceed_andAfterLimitExpirationWillClear {
    
    // mock
    __block VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    super.smsValidation = options.smsValidation;
    VDFBaseConfiguration *configuration = [[VDFSettings globalDIContainer] resolveForClass:[VDFBaseConfiguration class]];
    configuration.requestsThrottlingLimit = 2;
    configuration.requestsThrottlingPeriod = 2; // 2 seconds
    
    // stub success resolve 201
    [super stubRequest:[super filterResolveRequestWithSmsValidation]
     withResponsesList:@[[super responseResolve201], [super responseResolve201],
                         [super responseResolve201]]];
    
    // expect three responses with success:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted onSuccessExecution:^(VDFUserTokenDetails *details) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted onSuccessExecution:^(VDFUserTokenDetails *details) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusCompleted];
                    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // start next retrieve - this should exceed throttling limit
                });
            }];
            [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // start next retrieve
        });
    }];
    
    // expect one throttling limit exceeded error
    [super expectDidReceivedUserDetailsWithErrorCode:VDFErrorThrottlingLimitExceeded];
    
    // run
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.5]]; // wait 2.5 seconds
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // this return last completed status
    
    // verify
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY];
}


@end

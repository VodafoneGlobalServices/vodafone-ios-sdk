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

static NSInteger const VERIFY_DELAY = 8;

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

- (void)test_ResolutionIsFailed_InFirstStep {
    
    // mock
    super.smsValidation = NO;
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve with 404 response
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseEmptyWithCode:404]]];
    
    [super rejectAnyNotHandledHttpCall];
    
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // expect that the delegate object will be invoked correctly:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusFailed]; // for 404
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
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
    // 404 - failed
    [super stubRequest:[super filterCheckStatusRequest]
     withResponsesList:@[[super responseCheckStatus302NotFinishedAndRetryAfterMs:1000],
                         [super responseCheckStatus304NotModifiedAndRetryAfterMs:1000],
                         [super responseEmptyWithCode:404]]];
    
    [super rejectAnyNotHandledHttpCall];
    
    // expect that the delegate object will be invoked correctly:
    [super expectDidReceivedUserDetailsWithResolutionStatus:VDFResolutionStatusFailed];
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate];
    
    // verify
    [super.mockDelegate verifyWithDelay:10];
}






@end

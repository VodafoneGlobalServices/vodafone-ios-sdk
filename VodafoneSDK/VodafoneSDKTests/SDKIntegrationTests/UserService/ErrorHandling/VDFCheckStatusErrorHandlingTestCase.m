//
//  VDFCheckStatusErrorHandlingTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"

static NSInteger const VERIFY_DELAY = 3;

@interface VDFCheckStatusErrorHandlingTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFCheckStatusErrorHandlingTestCase

- (void)setUp
{
    [super setUp];
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // stub resolve with 302 - not finished
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[ [super responseResolve302NotFinishedAndRetryAfterMs:500] ]];
    
    // reject any unexpected response
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Testing error returned from first check status response

- (void)doTestForFirstCheckStatusResponse:(int)statusCode
                                errorCode:(VDFErrorCode)errorCode
                                  options:(VDFUserResolveOptions*)options {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub check status response with error:
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:@[ [super responseEmptyWithCode:statusCode] ]];
    
    // expect that the delegate object will be invoked correctly:
    [super expectDidReceivedUserDetailsWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}

#pragma mark for 500 response

- (void)test_FirstCheckStatusWithSmsValidationNO_500_Error {
    [self doTestForFirstCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_FirstCheckStatusWithSmsValidationYES_500_Error {
    [self doTestForFirstCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_FirstCheckStatusWithMSISDN_500_Error {
    [self doTestForFirstCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}


#pragma mark for 400 response

- (void)test_FirstCheckStatusWithSmsValidationNO_400_Error {
    [self doTestForFirstCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_FirstCheckStatusWithSmsValidationYES_400_Error {
    [self doTestForFirstCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_FirstCheckStatusWithMSISDN_400_Error {
    [self doTestForFirstCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}

#pragma mark for 403 response

- (void)test_FirstCheckStatusWithSmsValidationNO_403_Error {
    [self doTestForFirstCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_FirstCheckStatusWithSmsValidationYES_403_Error {
    [self doTestForFirstCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_FirstCheckStatusWithMSISDN_403_Error {
    [self doTestForFirstCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}



#pragma mark - Testing error returned from next check status responses

- (void)doTestCheckStatusResponse:(int)statusCode
                        errorCode:(VDFErrorCode)errorCode
                          options:(VDFUserResolveOptions*)options {
    
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub check status response with error:
    [super stubRequest:[super filterCheckStatusRequest] withResponsesList:@[[super responseCheckStatus304NotModifiedAndRetryAfterMs:500], [super responseEmptyWithCode:statusCode]]];
    
    // expect that the delegate object will be invoked correctly:
    [super expectDidReceivedUserDetailsWithErrorCode:errorCode];
    
    [super rejectAnyOtherDelegateCall];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}

#pragma mark for 500 response

- (void)test_CheckStatusWithSmsValidationNO_500_Error {
    [self doTestCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_CheckStatusWithSmsValidationYES_500_Error {
    [self doTestCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_CheckStatusWithMSISDN_500_Error {
    [self doTestCheckStatusResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}


#pragma mark for 400 response

- (void)test_CheckStatusWithSmsValidationNO_400_Error {
    [self doTestCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_CheckStatusWithSmsValidationYES_400_Error {
    [self doTestCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_CheckStatusWithMSISDN_400_Error {
    [self doTestCheckStatusResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}

#pragma mark for 403 response

- (void)test_CheckStatusWithSmsValidationNO_403_Error {
    [self doTestCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_CheckStatusWithSmsValidationYES_403_Error {
    [self doTestCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_CheckStatusWithMSISDN_403_Error {
    [self doTestCheckStatusResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}






@end

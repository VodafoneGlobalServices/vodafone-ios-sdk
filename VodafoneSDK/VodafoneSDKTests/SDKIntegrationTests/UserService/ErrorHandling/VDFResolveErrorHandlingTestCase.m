//
//  VDFResolveErrorHandlingTestCase.m
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

static NSInteger const VERIFY_DELAY = 8;

@interface VDFResolveErrorHandlingTestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFResolveErrorHandlingTestCase

- (void)setUp
{
    [super setUp];
    
    // stub http oauth
    [super stubRequest:[super filterOAuthRequest] withResponsesList:@[[super responseOAuthSuccessExpireInSeconds:3200]]];
    
    // reject any unexpected response
    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)doTestForEmptyHttpResponse:(int)statusCode errorCode:(VDFErrorCode)errorCode options:(VDFUserResolveOptions*)options {
    // mock
    super.smsValidation = options.smsValidation;
    
    // stub resolve with server 500 error
    [super stubRequest:[super filterResolveRequestWithSmsValidation] withResponsesList:@[[super responseEmptyWithCode:statusCode]]];
    
    // expect that the delegate object will be invoked correctly:
    [super expectDidReceivedUserDetailsWithErrorCode:errorCode];
    
    [super.serviceToTest retrieveUserDetails:options delegate:super.mockDelegate]; // run
    
    [super.mockDelegate verifyWithDelay:VERIFY_DELAY]; // verify
}

- (void)test_ResolveWithSmsValidationNO_500_Error {
    [self doTestForEmptyHttpResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolveWithSmsValidationYES_500_Error {
    [self doTestForEmptyHttpResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolveWithMSISDN_500_Error {
    [self doTestForEmptyHttpResponse:500 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}



- (void)test_ResolveWithSmsValidationNO_400_Error {
    [self doTestForEmptyHttpResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolveWithSmsValidationYES_400_Error {
    [self doTestForEmptyHttpResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolveWithMSISDN_400_Error {
    [self doTestForEmptyHttpResponse:400 errorCode:VDFErrorInvalidInput options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}



- (void)test_ResolveWithSmsValidationNO_401_Error {
    [self doTestForEmptyHttpResponse:401 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolveWithSmsValidationYES_401_Error {
    [self doTestForEmptyHttpResponse:401 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolveWithMSISDN_401_Error {
    [self doTestForEmptyHttpResponse:401 errorCode:VDFErrorServerCommunication options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}




- (void)test_ResolveWithSmsValidationNO_403_Error {
    [self doTestForEmptyHttpResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:NO]];
}

- (void)test_ResolveWithSmsValidationYES_403_Error {
    [self doTestForEmptyHttpResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithSmsValidation:YES]];
}

- (void)test_ResolveWithMSISDN_403_Error {
    [self doTestForEmptyHttpResponse:403 errorCode:VDFErrorOfResolution options:[[VDFUserResolveOptions alloc] initWithMSISDN:super.msisdn]];
}


@end

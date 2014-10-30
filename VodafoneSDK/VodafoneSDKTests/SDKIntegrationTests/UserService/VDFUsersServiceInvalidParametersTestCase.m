//
//  VDFUsersServiceInvalidParametersTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 30/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFTestCase.h"
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
#import "VDFUsersService.h"
#import "VDFSettings+Internal.h"
#import "VDFDIContainer.h"
#import "VDFBaseConfiguration.h"


@interface VDFUsersService ()
- (void)resetOneInstanceToken;
@end


@interface VDFUsersServiceInvalidParametersTestCase : VDFTestCase
@property VDFUsersService *serviceToTest;
@property id mockDelegate;
@end

@implementation VDFUsersServiceInvalidParametersTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [[VDFSettings globalDIContainer] registerInstance:nil forClass:[VDFBaseConfiguration class]];
    [[VDFUsersService sharedInstance] resetOneInstanceToken];
    self.serviceToTest = [VDFUsersService sharedInstance];
    self.mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    [VDFSettings initialize];
}

- (void)tearDown
{
    __block id serviceToStop = self.serviceToTest;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @try {
            [serviceToStop cancelRetrieveUserDetails];
        }
        @catch (NSException *exception) { }
    });
    
    [super tearDown];
}

- (void)assertIsAllServiceMethodsThrowingExceptionsWithOptions:(VDFUserResolveOptions*)options {
    XCTAssertThrows([self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate],
                    @"Call to UsersService prior to initialization of SDK should throw exception.");
    XCTAssertThrows([self.serviceToTest sendSmsPin],
                    @"Call to UsersService prior to initialization of SDK should throw exception.");
    XCTAssertThrows([self.serviceToTest validateSmsCode:@"1234"],
                    @"Call to UsersService prior to initialization of SDK should throw exception.");
    XCTAssertThrows([self.serviceToTest setDelegate:self.mockDelegate],
                    @"Call to UsersService prior to initialization of SDK should throw exception.");
    XCTAssertThrows([self.serviceToTest cancelRetrieveUserDetails],
                    @"Call to UsersService prior to initialization of SDK should throw exception.");
}

- (void)testCallsToService_OnNotInitializedSDK {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // run & assert
    [self assertIsAllServiceMethodsThrowingExceptionsWithOptions:options];
}


- (void)testCallsToService_OnNotFullyInitializedSDK {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // partial SDK init
    [VDFSettings initializeWithParams:@{ VDFClientAppKeySettingKey: @"asdasd" }];
    [[VDFUsersService sharedInstance] resetOneInstanceToken];
    self.serviceToTest = [VDFUsersService sharedInstance];
    // run & assert
    [self assertIsAllServiceMethodsThrowingExceptionsWithOptions:options];
    
    // partial SDK init
    [VDFSettings initializeWithParams:@{ VDFClientAppSecretSettingKey: @"asdasd" }];
    [[VDFUsersService sharedInstance] resetOneInstanceToken];
    self.serviceToTest = [VDFUsersService sharedInstance];
    // run & assert
    [self assertIsAllServiceMethodsThrowingExceptionsWithOptions:options];
    
    // partial SDK init
    [VDFSettings initializeWithParams:@{ VDFBackendAppKeySettingKey: @"asdasd" }];
    [[VDFUsersService sharedInstance] resetOneInstanceToken];
    self.serviceToTest = [VDFUsersService sharedInstance];
    // run & assert
    XCTAssertNoThrow([self.serviceToTest retrieveUserDetails:options delegate:self.mockDelegate],
                    @"Call to UsersService after full initialization of SDK should not throw exception.");
    XCTAssertNoThrow([self.serviceToTest sendSmsPin],
                     @"Call to UsersService after full initialization of SDK should not throw exception.");
    XCTAssertNoThrow([self.serviceToTest validateSmsCode:@"1234"],
                     @"Call to UsersService after full initialization of SDK should not throw exception.");
    XCTAssertNoThrow([self.serviceToTest setDelegate:self.mockDelegate],
                     @"Call to UsersService after full initialization of SDK should not throw exception.");
    XCTAssertNoThrow([self.serviceToTest cancelRetrieveUserDetails],
                    @"Call to UsersService after full initialization of SDK should not throw exception.");
}


@end

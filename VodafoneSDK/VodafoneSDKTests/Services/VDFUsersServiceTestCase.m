//
//  VDFUsersServiceTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersService.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFDIContainer.h"
#import "VDFBaseConfiguration.h"
#import "VDFSettings.h"
#import "VDFSettings+Internal.h"
#import "VDFServiceRequestsManager.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFRequestBuilderWithOAuth.h"
#import "VDFUserResolveRequestBuilder.h"
#import "VDFObserversContainer.h"
#import "VDFSmsSendPinRequestBuilder.h"
#import "VDFSmsValidationRequestBuilder.h"
#import "VDFUserResolveOptions.h"
#import "VDFUserResolveOptions+Internal.h"
#import "VDFDeviceUtility.h"

extern void __gcov_flush();

@interface VDFRequestBuilderWithOAuth ()
@property (nonatomic, strong) VDFRequestBaseBuilder *activeBuilder;
@property (nonatomic, assign) SEL selector;
@end

@interface VDFUsersService ()
@property (nonatomic, strong) VDFDIContainer *diContainer;
@end

@interface VDFUsersServiceTestCase : XCTestCase
@property VDFUsersService *serviceToTest;
@property VDFBaseConfiguration *configuration;
@property id mockServiceRequestsManager;
@property id mockDeviceUtility;
@end

@implementation VDFUsersServiceTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.serviceToTest = [[VDFUsersService alloc] init];
    self.configuration = [[VDFBaseConfiguration alloc] init];
    self.mockServiceRequestsManager = OCMClassMock([VDFServiceRequestsManager class]);
    
    self.mockDeviceUtility = OCMPartialMock([[VDFDeviceUtility alloc] init]);
    [[[self.mockDeviceUtility stub] andReturnValue:OCMOCK_VALUE(VDFNetworkAvailableViaWiFi)] checkNetworkTypeAvailability];
    
    id mockDIContainer = OCMClassMock([VDFDIContainer class]);
    [[[mockDIContainer stub] andReturn:self.configuration] resolveForClass:[VDFBaseConfiguration class]];
    [[[mockDIContainer stub] andReturn:self.mockServiceRequestsManager] resolveForClass:[VDFServiceRequestsManager class]];
    [[[mockDIContainer stub] andReturn:self.mockDeviceUtility] resolveForClass:[VDFDeviceUtility class]];
    
    self.serviceToTest.diContainer = mockDIContainer;
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testRetrieveUserDetailsWithInvalidData {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // run
    XCTAssertThrows([self.serviceToTest retrieveUserDetails:nil delegate:nil], @"start retrieve user details with nil options and nil delegate should throw error");
    XCTAssertThrows([self.serviceToTest retrieveUserDetails:options delegate:nil], @"start retrieve user details with nil delegate should throw error");
}

- (void)testRetrieveUserDetailsIsRequestPerformingProperly {
    
    // mock
    id options = OCMPartialMock([[VDFUserResolveOptions alloc] initWithSmsValidation:YES]);
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    [[[options stub] andReturn:@"12333444555"] msisdn];
    self.configuration.clientAppKey = @"some client app key";
    self.configuration.clientAppSecret = @"some client app secret";
    self.configuration.backendAppKey = @"some backend app key";
    self.configuration.phoneNumberRegex = @"^[0-9]{9}$";
    self.configuration.availableMarkets = @{@"AA": @12};
    
    // expect that the perform request will be invoked
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(![obj isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return NO;
        }
        VDFRequestBuilderWithOAuth *oAuthBuilder = (VDFRequestBuilderWithOAuth*)obj;
        if(![oAuthBuilder.activeBuilder isKindOfClass:[VDFUserResolveRequestBuilder class]]
           || oAuthBuilder.selector != @selector(setOAuthToken:)) {
            return NO;
        }
        
        VDFUserResolveRequestBuilder *innerBuilder = (VDFUserResolveRequestBuilder*)oAuthBuilder.activeBuilder;
        return [innerBuilder.clientAppKey isEqualToString:self.configuration.clientAppKey]
        &&[innerBuilder.clientAppSecret isEqualToString:self.configuration.clientAppSecret]
        &&[innerBuilder.backendAppKey isEqualToString:self.configuration.backendAppKey]
        && innerBuilder.requestOptions.smsValidation
        && [innerBuilder.requestOptions.market isEqualToString:@"AA"]
        && [[[innerBuilder observersContainer] registeredObservers] containsObject:mockDelegate];
    }]];
    
    // run
    [self.serviceToTest retrieveUserDetails:options delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

/*
 // TODO update this test to new method signature
 
- (void)testSendSmsPinWithInvalidData {
    
    // mock
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // expect that the perform request will be ivoked only once
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        VDFSmsSendPinRequestBuilder *innerBuilder = (VDFSmsSendPinRequestBuilder*)((VDFRequestBuilderWithOAuth*)obj).activeBuilder;
        return [innerBuilder.sessionToken isEqualToString:[NSString string]];
    }]];
    
    // expect that the perform request method will newer will be called after this one call
    [[self.mockServiceRequestsManager reject] performRequestWithBuilder:[OCMArg any]];
    
    // run
    [self.serviceToTest sendSmsPinInSession:nil]; // wont happend anything
    [self.serviceToTest sendSmsPinInSession:@"some session token"]; // wont happend anything too
    [self.serviceToTest sendSmsPinInSession:nil delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testSendSmsPinIsRequestPerformedProperly {
    
    // mock
    NSString *sessionToken = @"some session token";
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.clientAppKey = @"some client app key";
    self.configuration.clientAppSecret = @"some client app secret";
    self.configuration.backendAppKey = @"some backend app key";
    
    // expect that the perform request will be ivoked
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(![obj isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return NO;
        }
        VDFRequestBuilderWithOAuth *oAuthBuilder = (VDFRequestBuilderWithOAuth*)obj;
        if(![oAuthBuilder.activeBuilder isKindOfClass:[VDFSmsSendPinRequestBuilder class]]
           || oAuthBuilder.selector != @selector(setOAuthToken:)) {
            return NO;
        }
        
        VDFSmsSendPinRequestBuilder *innerBuilder = (VDFSmsSendPinRequestBuilder*)oAuthBuilder.activeBuilder;
        return [innerBuilder.clientAppKey isEqualToString:self.configuration.clientAppKey]
        &&[innerBuilder.clientAppSecret isEqualToString:self.configuration.clientAppSecret]
        &&[innerBuilder.backendAppKey isEqualToString:self.configuration.backendAppKey]
        && [innerBuilder.sessionToken isEqualToString:sessionToken]
        && [[[innerBuilder observersContainer] registeredObservers] containsObject:mockDelegate];
    }]];
    
    // run
    [self.serviceToTest sendSmsPinInSession:sessionToken delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testValidateSmsPinWithInvalidData {
    
    // mock
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // expect that the perform request will be ivoked only once
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        VDFSmsValidationRequestBuilder *innerBuilder = (VDFSmsValidationRequestBuilder*)((VDFRequestBuilderWithOAuth*)obj).activeBuilder;
        return [innerBuilder.sessionToken isEqualToString:[NSString string]]
        && [innerBuilder.smsCode isEqualToString:[NSString string]];
    }]];
    
    // expect that the perform request method will newer will be called after this one call
    [[self.mockServiceRequestsManager reject] performRequestWithBuilder:[OCMArg any]];
    
    // run
    [self.serviceToTest validateSmsCode:nil inSession:nil delegate:nil]; // wont happend anything
    [self.serviceToTest validateSmsCode:nil inSession:@"some session token" delegate:nil]; // wont happend anything too
    [self.serviceToTest validateSmsCode:@"some pin" inSession:@"some session token" delegate:nil]; // wont happend anything too
    [self.serviceToTest validateSmsCode:nil inSession:nil delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testValidateSmsPinIsRequestPerformedProperly {
    
    // mock
    NSString *smsCode = @"some sms pin code";
    NSString *sessionToken = @"some session token";
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.clientAppKey = @"some client app key";
    self.configuration.clientAppSecret = @"some client app secret";
    self.configuration.backendAppKey = @"some backend app key";
    
    // expect that the perform request will be ivoked
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(![obj isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return NO;
        }
        VDFRequestBuilderWithOAuth *oAuthBuilder = (VDFRequestBuilderWithOAuth*)obj;
        if(![oAuthBuilder.activeBuilder isKindOfClass:[VDFSmsValidationRequestBuilder class]]
           || oAuthBuilder.selector != @selector(setOAuthToken:)) {
            return NO;
        }
        
        VDFSmsValidationRequestBuilder *innerBuilder = (VDFSmsValidationRequestBuilder*)oAuthBuilder.activeBuilder;
        return [innerBuilder.clientAppKey isEqualToString:self.configuration.clientAppKey]
        &&[innerBuilder.clientAppSecret isEqualToString:self.configuration.clientAppSecret]
        &&[innerBuilder.backendAppKey isEqualToString:self.configuration.backendAppKey]
        && [innerBuilder.sessionToken isEqualToString:sessionToken]
        && [innerBuilder.smsCode isEqualToString:smsCode]
        && [[[innerBuilder observersContainer] registeredObservers] containsObject:mockDelegate];
    }]];
    
    // run
    [self.serviceToTest validateSmsCode:smsCode inSession:sessionToken delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testRemoveDelegate {
    
    // mock
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // expect that the request manager will be invoked only once
    [[self.mockServiceRequestsManager expect] removeRequestObserver:mockDelegate];
    
    // expect that the requests manager wont be invoked any more
    [[self.mockServiceRequestsManager reject] removeRequestObserver:[OCMArg any]];
    
    // run
    [self.serviceToTest removeDelegate:nil]; // wont happend anything
    [self.serviceToTest removeDelegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}
*/

@end

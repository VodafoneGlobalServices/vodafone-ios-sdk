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

extern void __gcov_flush();

@interface VDFRequestBuilderWithOAuth ()
@property (nonatomic, strong) VDFRequestBaseBuilder *builder;
@property (nonatomic, assign) SEL selector;
@end

@interface VDFUsersService ()
@property (nonatomic, strong) VDFDIContainer *diContainer;
@end

@interface VDFUsersServiceTestCase : XCTestCase
@property VDFUsersService *serviceToTest;
@property VDFBaseConfiguration *configuration;
@property id mockServiceRequestsManager;
@end

@implementation VDFUsersServiceTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.serviceToTest = [[VDFUsersService alloc] init];
    self.configuration = [[VDFBaseConfiguration alloc] init];
    self.mockServiceRequestsManager = OCMClassMock([VDFServiceRequestsManager class]);
    
    id mockDIContainer = OCMClassMock([VDFDIContainer class]);
    [[[mockDIContainer stub] andReturn:self.configuration] resolveForClass:[VDFBaseConfiguration class]];
    [[[mockDIContainer stub] andReturn:self.mockServiceRequestsManager] resolveForClass:[VDFServiceRequestsManager class]];
    
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
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithValidateWithSms:NO];
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.applicationId = nil;
    
    // expect that the perform request will be ivoked only once
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        VDFUserResolveRequestBuilder *innerBuilder = (VDFUserResolveRequestBuilder*)((VDFRequestBuilderWithOAuth*)obj).builder;
        return [innerBuilder.applicationId isEqualToString:[NSString string]] && innerBuilder.requestOptions.validateWithSms == NO;
    }]];
    
    // expect that the perform request method will newer will be called after this one call
    [[self.mockServiceRequestsManager reject] performRequestWithBuilder:[OCMArg any]];
    
    // run
    [self.serviceToTest retrieveUserDetails:nil delegate:nil]; // wont happend anything
    [self.serviceToTest retrieveUserDetails:options delegate:nil]; // wont happend anything too
    [self.serviceToTest retrieveUserDetails:nil delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testRetrieveUserDetailsIsRequestPerformingProperly {
    
    // mock
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithValidateWithSms:YES];
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.applicationId = @"some app id";
    
    // expect that the perform request will be ivoked
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(![obj isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return NO;
        }
        VDFRequestBuilderWithOAuth *oAuthBuilder = (VDFRequestBuilderWithOAuth*)obj;
        if(![oAuthBuilder.builder isKindOfClass:[VDFUserResolveRequestBuilder class]]
           || oAuthBuilder.selector != @selector(setOAuthToken:)) {
            return NO;
        }
        
        VDFUserResolveRequestBuilder *innerBuilder = (VDFUserResolveRequestBuilder*)oAuthBuilder.builder;
        return [innerBuilder.applicationId isEqualToString:self.configuration.applicationId]
        && innerBuilder.requestOptions.validateWithSms
        && [[[innerBuilder observersContainer] registeredObservers] containsObject:mockDelegate];
    }]];
    
    // run
    [self.serviceToTest retrieveUserDetails:options delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testSendSmsPinWithInvalidData {
    
    // mock
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.applicationId = nil;
    
    // expect that the perform request will be ivoked only once
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        VDFSmsSendPinRequestBuilder *innerBuilder = (VDFSmsSendPinRequestBuilder*)((VDFRequestBuilderWithOAuth*)obj).builder;
        return [innerBuilder.applicationId isEqualToString:[NSString string]] && [innerBuilder.sessionToken isEqualToString:[NSString string]];
    }]];
    
    // expect that the perform request method will newer will be called after this one call
    [[self.mockServiceRequestsManager reject] performRequestWithBuilder:[OCMArg any]];
    
    // run
    [self.serviceToTest sendSmsPinWithSession:nil delegate:nil]; // wont happend anything
    [self.serviceToTest sendSmsPinWithSession:@"some session token" delegate:nil]; // wont happend anything too
    [self.serviceToTest sendSmsPinWithSession:nil delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testSendSmsPinIsRequestPerformedProperly {
    
    // mock
    NSString *sessionToken = @"some session token";
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.applicationId = @"some app id";
    
    // expect that the perform request will be ivoked
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(![obj isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return NO;
        }
        VDFRequestBuilderWithOAuth *oAuthBuilder = (VDFRequestBuilderWithOAuth*)obj;
        if(![oAuthBuilder.builder isKindOfClass:[VDFSmsSendPinRequestBuilder class]]
           || oAuthBuilder.selector != @selector(setOAuthToken:)) {
            return NO;
        }
        
        VDFSmsSendPinRequestBuilder *innerBuilder = (VDFSmsSendPinRequestBuilder*)oAuthBuilder.builder;
        return [innerBuilder.applicationId isEqualToString:self.configuration.applicationId]
        && [innerBuilder.sessionToken isEqualToString:sessionToken]
        && [[[innerBuilder observersContainer] registeredObservers] containsObject:mockDelegate];
    }]];
    
    // run
    [self.serviceToTest sendSmsPinWithSession:sessionToken delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testValidateSmsPinWithInvalidData {
    
    // mock
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.applicationId = nil;
    
    // expect that the perform request will be ivoked only once
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        VDFSmsValidationRequestBuilder *innerBuilder = (VDFSmsValidationRequestBuilder*)((VDFRequestBuilderWithOAuth*)obj).builder;
        return [innerBuilder.applicationId isEqualToString:[NSString string]]
        && [innerBuilder.sessionToken isEqualToString:[NSString string]]
        && [innerBuilder.smsCode isEqualToString:[NSString string]];
    }]];
    
    // expect that the perform request method will newer will be called after this one call
    [[self.mockServiceRequestsManager reject] performRequestWithBuilder:[OCMArg any]];
    
    // run
    [self.serviceToTest validateSmsPin:nil withSessionToken:nil delegate:nil]; // wont happend anything
    [self.serviceToTest validateSmsPin:nil withSessionToken:@"some session token" delegate:nil]; // wont happend anything too
    [self.serviceToTest validateSmsPin:@"some pin" withSessionToken:@"some session token" delegate:nil]; // wont happend anything too
    [self.serviceToTest validateSmsPin:nil withSessionToken:nil delegate:mockDelegate];
    
    // verify
    [self.mockServiceRequestsManager verify];
}

- (void)testValidateSmsPinIsRequestPerformedProperly {
    
    // mock
    NSString *smsPin = @"some sms pin code";
    NSString *sessionToken = @"some session token";
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub
    self.configuration.applicationId = @"some app id";
    
    // expect that the perform request will be ivoked
    [[self.mockServiceRequestsManager expect] performRequestWithBuilder:[OCMArg checkWithBlock:^BOOL(id obj) {
        if(![obj isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return NO;
        }
        VDFRequestBuilderWithOAuth *oAuthBuilder = (VDFRequestBuilderWithOAuth*)obj;
        if(![oAuthBuilder.builder isKindOfClass:[VDFSmsValidationRequestBuilder class]]
           || oAuthBuilder.selector != @selector(setOAuthToken:)) {
            return NO;
        }
        
        VDFSmsValidationRequestBuilder *innerBuilder = (VDFSmsValidationRequestBuilder*)oAuthBuilder.builder;
        return [innerBuilder.applicationId isEqualToString:self.configuration.applicationId]
        && [innerBuilder.sessionToken isEqualToString:sessionToken]
        && [innerBuilder.smsCode isEqualToString:smsPin]
        && [[[innerBuilder observersContainer] registeredObservers] containsObject:mockDelegate];
    }]];
    
    // run
    [self.serviceToTest validateSmsPin:smsPin withSessionToken:sessionToken delegate:mockDelegate];
    
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

@end

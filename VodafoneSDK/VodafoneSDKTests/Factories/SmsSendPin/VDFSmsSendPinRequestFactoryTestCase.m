//
//  VDFSmsSendPinRequestFactoryTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFRequestFactory.h"
#import "VDFFactoryBaseTestCase.h"
#import "VDFArrayObserversContainer.h"
#import "VDFRequestState.h"
#import "VDFCacheObject.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnector.h"
#import "VDFSmsSendPinRequestFactory.h"
#import "VDFSmsSendPinRequestBuilder.h"
#import "VDFSmsSendPinRequestState.h"
#import "VDFSmsSendPinResponseParser.h"
#import "VDFHttpConnectorDelegate.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFSettings.h"


@interface VDFSmsSendPinRequestFactoryTestCase : VDFFactoryBaseTestCase
@property VDFSmsSendPinRequestFactory *factoryToTest;
@property id mockBuilder;
@property id factoryToTestMock;
@property VDFBaseConfiguration *configuration;
@end

@implementation VDFSmsSendPinRequestFactoryTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockBuilder = OCMClassMock([VDFSmsSendPinRequestBuilder class]);
    self.factoryToTest = [[VDFSmsSendPinRequestFactory alloc] initWithBuilder:self.mockBuilder];
    self.factoryToTestMock = OCMPartialMock(self.factoryToTest);
    self.configuration = [[VDFBaseConfiguration alloc] init];
    
    // stubs
    [[[self.mockBuilder stub] andReturn:self.configuration] configuration];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateResponseParser {
    [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                         selector: @selector(createResponseParser)
                              expectedResultClass: [VDFSmsSendPinResponseParser class]];
}

- (void)testCreateRequestState {
    [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                         selector: @selector(createRequestState)
                              expectedResultClass: [VDFSmsSendPinRequestState class]];
}

- (void)testCreateObserversContainer {
    VDFArrayObserversContainer *result = [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                                                              selector: @selector(createObserversContainer)
                                                                   expectedResultClass: [VDFArrayObserversContainer class]];
    
    XCTAssertEqual(result.notifySelector, @selector(didSMSPinRequested:withError:), @"Selector set to observers container is invalid");
}

- (void)testCreateCacheObject {
    
    // run
    id result = [self.factoryToTest createCacheObject];
    
    // assert
    XCTAssertNil(result, @"Cache object should be nil because we do not cache responses of this request.");
}

- (void)testCreateHttpConnectorRequest {
    
    // mock
    id mockDelegate =OCMProtocolMock(@protocol(VDFHttpConnectorDelegate));
    id mockOAuthToken = OCMClassMock([VDFOAuthTokenResponse class]);
    
    // stubs
    self.configuration.apixBaseUrl = @"http://someUrl.com/";
    self.configuration.defaultHttpConnectionTimeout = 100;
    [[[self.mockBuilder stub] andReturn:@"some/endpoint/method"] urlEndpointQuery];
    [[[self.mockBuilder stub] andReturnValue:OCMOCK_VALUE(HTTPMethodGET)] httpRequestMethodType];
    [[[self.mockBuilder stub] andReturn:mockOAuthToken] oAuthToken];
    [[[mockOAuthToken stub] andReturn:@"Barier"] tokenType];
    [[[mockOAuthToken stub] andReturn:@"asd"] accessToken];
    [[[self.mockBuilder stub] andReturn:@"appID"] applicationId];
    
    // run
    VDFHttpConnector *result = [self.factoryToTestMock createHttpConnectorRequestWithDelegate:mockDelegate];
    
    // assert
    XCTAssertEqualObjects(result.delegate, mockDelegate, @"Delegate object was not proeprly set on Http connector object.");
    XCTAssertEqual(result.connectionTimeout, (NSTimeInterval)100, @"Default connection time out from configuration was not set.");
    XCTAssertEqual(result.methodType, HTTPMethodGET, @"Http method type was not set from builder.");
    XCTAssertFalse(result.isGSMConnectionRequired, @"GSM Connection is not required for this factory.");
    XCTAssertNil(result.postBody, @"Post Body need to be nil.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"Authorization"], @"Barier asd", @"Authorization header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"User-Agent"], [VDFSettings sdkVersion], @"User-Agent header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"Application-ID"], @"appID", @"User-Agent header was not set.");
    XCTAssertEqualObjects(result.url, @"http://someUrl.com/some/endpoint/method", @"Url was not set proeprly.");
}



@end

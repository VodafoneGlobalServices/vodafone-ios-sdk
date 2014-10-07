//
//  VDFUserResolveRequestFactoryTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 26/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFRequestFactory.h"
#import "VDFFactoryBaseTestCase.h"
#import "VDFArrayObserversContainer.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnector.h"
#import "VDFUserResolveOptions.h"
#import "VDFUserResolveRequestBuilder.h"
#import "VDFUserResolveRequestFactory.h"
#import "VDFUserResolveRequestState.h"
#import "VDFUserResolveResponseParser.h"
#import "VDFSettings.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFDIContainer.h"
#import "VDFConsts.h"
#import "VDFUserResolveOptions+Internal.h"

@interface VDFUserResolveRequestFactory ()
- (NSData*)postBody;
@end

@interface VDFUserResolveRequestFactoryTestCase : VDFFactoryBaseTestCase
@property VDFUserResolveRequestFactory *factoryToTest;
@property id mockBuilder;
@property id mockCurrentState;
@property id factoryToTestMock;
@property VDFBaseConfiguration *configuration;
@end

@implementation VDFUserResolveRequestFactoryTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockBuilder = OCMClassMock([VDFUserResolveRequestBuilder class]);
    self.mockCurrentState = OCMProtocolMock(@protocol(VDFRequestState));
    
    self.factoryToTest = [[VDFUserResolveRequestFactory alloc] initWithBuilder:self.mockBuilder];
    self.factoryToTestMock = OCMPartialMock(self.factoryToTest);
    
    self.configuration = [[VDFBaseConfiguration alloc] init];
    
    id mockDIContainer = OCMClassMock([VDFDIContainer class]);
    [[[mockDIContainer stub] andReturn:self.configuration] resolveForClass:[VDFBaseConfiguration class]];
    
    // stubs
    [[[self.mockBuilder stub] andReturn:self.mockCurrentState] requestState];
    [[[self.mockBuilder stub] andReturn:mockDIContainer] diContainer];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.factoryToTestMock stopMocking];
}


- (void)testCreateResponseParser {
    [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                         selector: @selector(createResponseParser)
                              expectedResultClass: [VDFUserResolveResponseParser class]];
}

- (void)testCreateRequestState {
    [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                         selector: @selector(createRequestState)
                              expectedResultClass: [VDFUserResolveRequestState class]];
}

- (void)testCreateObserversContainer {
    VDFArrayObserversContainer *result = [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                                                              selector: @selector(createObserversContainer)
                                                                   expectedResultClass: [VDFArrayObserversContainer class]];
    
    XCTAssertEqual(result.notifySelector, @selector(didReceivedUserDetails:withError:), @"Selector set to observers container is invalid");
}

- (void)testCreateCacheObject {
    // run
    id result = [self.factoryToTest createCacheObject];
    // assert
    XCTAssertNil(result, @"Cache object should be nil because we do not cache responses of this request.");
}

- (void)testCreateHttpConnectorInitialRequest {
    
    // mock
    id mockDelegate =OCMProtocolMock(@protocol(VDFHttpConnectorDelegate));
    NSData *postBodyContent = [NSData data];
    id mockOAuthToken = OCMClassMock([VDFOAuthTokenResponse class]);
    
    // stubs
    self.configuration.hapHost = @"http://someUrl.com/";
    self.configuration.defaultHttpConnectionTimeout = 100;
    [[[self.mockBuilder stub] andReturn:@"some/endpoint/method"] initialUrlEndpointQuery];
    [[[self.mockBuilder stub] andReturnValue:OCMOCK_VALUE(HTTPMethodPOST)] httpRequestMethodType];
    [[[self.factoryToTestMock stub] andReturn:postBodyContent] postBody];
    [[[self.mockBuilder stub] andReturn:mockOAuthToken] oAuthToken];
    [[[mockOAuthToken stub] andReturn:@"Barier"] tokenType];
    [[[mockOAuthToken stub] andReturn:@"asd"] accessToken];
    [[[self.mockBuilder stub] andReturn:@"clientAppKey"] clientAppKey];
    [[[self.mockBuilder stub] andReturn:@"clientAppSecret"] clientAppSecret];
    [[[self.mockBuilder stub] andReturn:@"backendAppKey"] backendAppKey];
    
    // run
    VDFHttpConnector *result = [self.factoryToTestMock createHttpConnectorRequestWithDelegate:mockDelegate];
    
    // assert
    XCTAssertEqualObjects(result.delegate, mockDelegate, @"Delegate object was not proeprly set on Http connector object.");
    XCTAssertEqual(result.connectionTimeout, (NSTimeInterval)100, @"Default connection time out from configuration was not set.");
    XCTAssertEqual(result.methodType, HTTPMethodPOST, @"Http method type was not set from builder.");
    XCTAssertEqualObjects(result.postBody, postBodyContent, @"Post Body was not set proeprly.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:HTTP_HEADER_CONTENT_TYPE], @"application/json", @"Content-Type header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:HTTP_HEADER_AUTHORIZATION], @"Barier asd", @"Authorization header was not set.");
    XCTAssertEqualObjects(result.url, @"http://someUrl.com/some/endpoint/method", @"Url was not set proeprly.");
    
    // TODO IMPORTANT when it will be attached to production servers (not mockups) then uncomment this
    //    XCTAssertTrue(result.isGSMConnectionRequired, @"GSM Connection is required for this factory.");
}

- (void)testCreateHttpConnectorRetryRequest {
    
    // mock
    id mockDelegate =OCMProtocolMock(@protocol(VDFHttpConnectorDelegate));
    id mockOAuthToken = OCMClassMock([VDFOAuthTokenResponse class]);
    
    // stubs
    self.configuration.apixHost = @"http://someUrl.com/";
    self.configuration.defaultHttpConnectionTimeout = 100;
    [[[self.mockBuilder stub] andReturn:@"some/endpoint/method"] retryUrlEndpointQuery];
    [[[self.mockBuilder stub] andReturn:mockOAuthToken] oAuthToken];
    [[[mockOAuthToken stub] andReturn:@"Barier"] tokenType];
    [[[mockOAuthToken stub] andReturn:@"asd"] accessToken];
    [[[self.mockBuilder stub] andReturn:@"clientAppKey"] clientAppKey];
    [[[self.mockBuilder stub] andReturn:@"clientAppSecret"] clientAppSecret];
    [[[self.mockBuilder stub] andReturn:@"backendAppKey"] backendAppKey];
    [[[self.mockBuilder stub] andReturn:@"etagtest"] eTag];
    
    // run
    VDFHttpConnector *result = [self.factoryToTestMock createRetryHttpConnectorWithDelegate:mockDelegate];
    
    // assert
    XCTAssertEqualObjects(result.delegate, mockDelegate, @"Delegate object was not proeprly set on Http connector object.");
    XCTAssertEqual(result.connectionTimeout, (NSTimeInterval)100, @"Default connection time out from configuration was not set.");
    XCTAssertEqual(result.methodType, HTTPMethodGET, @"Http method type was not set from builder.");
    XCTAssertNil(result.postBody, @"Post Body need to be nil.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:HTTP_HEADER_AUTHORIZATION], @"Barier asd", @"Authorization header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:HTTP_HEADER_IF_NONE_MATCH], @"etagtest", @"ETag header was not set.");
    XCTAssertEqualObjects(result.url, @"http://someUrl.com/some/endpoint/method", @"Url was not set proeprly.");
    XCTAssertFalse(result.isGSMConnectionRequired, @"GSM Connection is not required for this factory.");
}

- (void)testPostBodyIsGeneratedProperlyWithSmsValidation {
    
    // mock
    id optionsWithSms = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    
    // stub
    [[[self.mockBuilder stub] andReturn:optionsWithSms] requestOptions];
    
    // run
    NSData *resultWithSms = [self.factoryToTestMock postBody];
    
    // assert
    NSString *resultWithSmsString = [[NSString alloc] initWithData:resultWithSms encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(resultWithSmsString, @"{\n  \"smsValidation\" : \"false\"\n}", @"Post body is generated not properly.");
}

- (void)testPostBodyIsGeneratedProperlyWithMSISDN {
    
    // mock
    VDFUserResolveOptions *optionsWithMSISDN = [[VDFUserResolveOptions alloc] initWithMSISDN:@"some msisdn"];
    optionsWithMSISDN.market = @"some market";
    
    // stub
    [[[self.mockBuilder stub] andReturn:optionsWithMSISDN] requestOptions];
    
    // run
    NSData *resultWithMSISDN = [self.factoryToTestMock postBody];
    
    // assert
    NSString *resultWithMSISDNString = [[NSString alloc] initWithData:resultWithMSISDN encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(resultWithMSISDNString, @"{\n  \"smsValidation\" : \"true\",\n  \"market\" : \"some market\",\n  \"msisdn\" : \"some msisdn\"\n}", @"Post body is generated not properly.");
}

@end

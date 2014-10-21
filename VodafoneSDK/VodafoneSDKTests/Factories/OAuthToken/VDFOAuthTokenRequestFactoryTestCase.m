//
//  VDFOAuthTokenRequestFactoryTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFRequestFactory.h"
#import "VDFOAuthTokenRequestFactory.h"
#import "VDFOAuthTokenRequestBuilder.h"
#import "VDFOAuthTokenResponseParser.h"
#import "VDFOAuthTokenRequestState.h"
#import "VDFFactoryBaseTestCase.h"
#import "VDFArrayObserversContainer.h"
#import "VDFRequestState.h"
#import "VDFCacheObject.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnector.h"
#import "VDFOAuthTokenRequestOptions.h"
#import "VDFDIContainer.h"

#pragma mark -
#pragma mark - Private properties/methods of mocked/tested classes

@interface VDFOAuthTokenRequestFactory ()
@property (nonatomic, strong) VDFOAuthTokenRequestBuilder *builder;

- (NSData*)postBody;
@end

#pragma mark -
#pragma mark - test case class

@interface VDFOAuthTokenRequestFactoryTestCase : VDFFactoryBaseTestCase
@property VDFOAuthTokenRequestFactory *factoryToTest;
@property id mockBuilder;
@property id mockCurrentState;
@property id factoryToTestMock;
@property VDFBaseConfiguration *mockConfiguration;
@property id mockDIContainer;

- (VDFCacheObject*)createTestCacheObjectWithUrl:(NSString*)url postBody:(NSData*)body;
@end

@implementation VDFOAuthTokenRequestFactoryTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockBuilder = OCMClassMock([VDFOAuthTokenRequestBuilder class]);
    self.mockCurrentState = OCMProtocolMock(@protocol(VDFRequestState));
    
    self.factoryToTest = [[VDFOAuthTokenRequestFactory alloc] initWithBuilder:self.mockBuilder];
    self.factoryToTestMock = OCMPartialMock(self.factoryToTest);
    
    self.mockConfiguration = [[VDFBaseConfiguration alloc] init];
    
    self.mockDIContainer = OCMClassMock([VDFDIContainer class]);
    [[[self.mockDIContainer stub] andReturn:self.mockConfiguration] resolveForClass:[VDFBaseConfiguration class]];
    
    // stubs
    [[[self.mockBuilder stub] andReturn:self.mockCurrentState] requestState];
    [[[self.mockBuilder stub] andReturn:self.mockDIContainer] diContainer];
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
                              expectedResultClass: [VDFOAuthTokenResponseParser class]];
}

- (void)testCreateRequestState {
    [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                         selector: @selector(createRequestState)
                              expectedResultClass: [VDFOAuthTokenRequestState class]];
}

- (void)testCreateObserversContainer {
    VDFArrayObserversContainer *result = [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                                     selector: @selector(createObserversContainer)
                                          expectedResultClass: [VDFArrayObserversContainer class]];
    
    XCTAssertEqual(result.notifySelector, @selector(didReceivedOAuthToken:withError:), @"Selector set to observers container is invalid");
}

- (void)testCreateCacheObject {
    
    // mock
    NSDate *expirationDate = [NSDate date];
    NSData *postBodyContent = [NSData data];
    
    // stub
    [[[self.mockCurrentState stub] andReturn:expirationDate] lastResponseExpirationDate];
    [[[self.factoryToTestMock stub] andReturn:postBodyContent] postBody];
    
    // run
    VDFCacheObject *result = [self.factoryToTest createCacheObject];
    
    // assert
    XCTAssertNil(result.cacheValue, @"Created cache object should have value set to nil.");
    XCTAssertNotNil(result.cacheKey, @"Created cache object should have key should not be nil.");
    XCTAssertNotEqual(result.cacheKey, @"", @"Created cache object should have key should not be empty.");
    XCTAssertEqualObjects(result.expirationDate, expirationDate, @"Created cache object should have set the expiration date properly from current state object.");
}

- (void)testCreateCacheObjectIsCacheKeyGeneratedProperly {
    
    // mock
    NSData *postBodyContent = [NSData data];
    
    // run
    VDFCacheObject *result1 = [self createTestCacheObjectWithUrl:@"some/url" postBody:postBodyContent];
    VDFCacheObject *resultDiffUrlEndpoint = [self createTestCacheObjectWithUrl:@"some/url/different" postBody:postBodyContent];
    VDFCacheObject *resultDiffData = [self createTestCacheObjectWithUrl:@"some/url" postBody:[@"some data" dataUsingEncoding:NSUTF8StringEncoding]];
    VDFCacheObject *result2 = [self createTestCacheObjectWithUrl:@"some/url" postBody:postBodyContent];
    
    // assert
    XCTAssertEqualObjects(result1.cacheKey, result2.cacheKey, @"Cache key for the same requests should be the same.");
    XCTAssertNotEqualObjects(result1.cacheKey, resultDiffUrlEndpoint.cacheKey, @"Cache Key should be diffrent for different request parameters.");
    XCTAssertNotEqualObjects(result1.cacheKey, resultDiffData.cacheKey, @"Cache Key should be diffrent for different request parameters.");
    XCTAssertNotEqualObjects(resultDiffUrlEndpoint.cacheKey, resultDiffData.cacheKey, @"Cache Key should be diffrent for different request parameters.");
}


- (void)testCreateHttpConnectorRequest {
    
    // mock
    id mockDelegate =OCMProtocolMock(@protocol(VDFOAuthTokenRequestDelegate));
    NSData *postBodyContent = [NSData data];
    
    // stubs
    self.mockConfiguration.apixHost = @"http://someUrl.com/";
    self.mockConfiguration.defaultHttpConnectionTimeout = 100;
    self.mockConfiguration.oAuthTokenUrlPath = @"some/endpoint/method";
    [[[self.factoryToTestMock stub] andReturn:postBodyContent] postBody];
    
    // run
    VDFHttpConnector *result = [self.factoryToTestMock createHttpConnectorRequestWithDelegate:mockDelegate];
    
    // assert
    XCTAssertEqualObjects(result.delegate, mockDelegate, @"Delegate object was not proeprly set on Http connector object.");
    XCTAssertEqual(result.connectionTimeout, (NSTimeInterval)100, @"Default connection time out from configuration was not set.");
    XCTAssertEqual(result.methodType, HTTPMethodPOST, @"Http method type was not set from builder.");
    XCTAssertEqualObjects(result.postBody, postBodyContent, @"Post Body was not set proeprly.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"Accept"], @"application/json", @"Accept header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"Content-Type"], @"application/x-www-form-urlencoded", @"Content-Type header was not set.");
    XCTAssertEqualObjects(result.url, @"http://someUrl.com/some/endpoint/method", @"Url was not set proeprly.");
    XCTAssertFalse(result.isGSMConnectionRequired, @"GSM Connection is not required for this factory.");
}

- (void)testPostBodyCreationWithoutScopes {
    
    // mock
    VDFOAuthTokenRequestOptions *requestOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    requestOptions.clientId = @"someClientID";
    requestOptions.clientSecret = @"someClientSecret";
    self.mockConfiguration.oAuthTokenGrantType = @"SomeGrantType";
    
    // stub
    [[[self.mockBuilder stub] andReturn:requestOptions] requestOptions];
    
    // run
    NSData *result = [self.factoryToTestMock postBody];
    
    // assert
    XCTAssertEqualObjects([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding],
                          @"grant_type=SomeGrantType&client_id=someClientID&client_secret=someClientSecret",
                          @"Post body is generated not properly.");
}

- (void)testPostBodyCreationWithScopes {
    
    // mock
    VDFOAuthTokenRequestOptions *requestOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    requestOptions.clientId = @"someClientID";
    requestOptions.clientSecret = @"someClientSecret";
    requestOptions.scopes = @[@"scopeOne", @"scopeTwo"];
    self.mockConfiguration.oAuthTokenGrantType = @"someGrantType";
    
    // stub
    [[[self.mockBuilder stub] andReturn:requestOptions] requestOptions];
    
    // run
    NSData *result = [self.factoryToTestMock postBody];
    
    // assert
    XCTAssertEqualObjects([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding],
                          @"grant_type=someGrantType&client_id=someClientID&client_secret=someClientSecret&scope=scopeOne&scope=scopeTwo",
                          @"Post body is generated not properly.");
}

- (void)testPostBodyCreationWithOneScope {
    
    // mock
    VDFOAuthTokenRequestOptions *requestOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    requestOptions.clientId = @"someClientID";
    requestOptions.clientSecret = @"someClientSecret";
    requestOptions.scopes = @[@"scopeOne"];
    self.mockConfiguration.oAuthTokenGrantType = @"someGrantType";
    
    // stub
    [[[self.mockBuilder stub] andReturn:requestOptions] requestOptions];
    
    // run
    NSData *result = [self.factoryToTestMock postBody];
    
    // assert
    XCTAssertEqualObjects([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding],
                          @"grant_type=someGrantType&client_id=someClientID&client_secret=someClientSecret&scope=scopeOne",
                          @"Post body is generated not properly.");
}


#pragma mark -
#pragma mark - helper method
- (VDFCacheObject*)createTestCacheObjectWithUrl:(NSString*)url postBody:(NSData*)body {
    
    // mock
    VDFBaseConfiguration *mockConfiguration = [[VDFBaseConfiguration alloc] init];
    mockConfiguration.apixHost = @"http://apix.com";
    mockConfiguration.oAuthTokenUrlPath = url;
    VDFDIContainer *diContainer = [[VDFDIContainer alloc] init];
    id localMockBuilder = OCMClassMock([VDFOAuthTokenRequestBuilder class]);
    id localFactoryToTest = [[VDFOAuthTokenRequestFactory alloc] initWithBuilder:localMockBuilder];
    id localMockactoryToTest = OCMPartialMock(localFactoryToTest);
    
    // stubs
    [[[localMockactoryToTest stub] andReturn:body] postBody];
    [diContainer registerInstance:mockConfiguration forClass:[VDFBaseConfiguration class]];
    [[[localMockBuilder stub] andReturn:diContainer] diContainer];
    
    // run
    return [localMockactoryToTest createCacheObject];
}


@end

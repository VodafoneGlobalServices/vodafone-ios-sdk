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
@property VDFBaseConfiguration *diContainer;

- (VDFCacheObject*)createTestCacheObjectWithUrl:(NSString*)url httpMethod:(HTTPMethodType)methodType postBody:(NSData*)body;
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
    
    self.configuration = [[VDFBaseConfiguration alloc] init];
    
    // stubs
    [[[self.mockBuilder stub] andReturn:self.mockCurrentState] requestState];
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
    [[[self.mockBuilder stub] andReturn:@"some/url"] urlEndpointQuery];
    [[[self.mockBuilder stub] andReturnValue:OCMOCK_VALUE(HTTPMethodGET)] httpRequestMethodType];
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
    VDFCacheObject *result1 = [self createTestCacheObjectWithUrl:@"some/url" httpMethod:HTTPMethodGET postBody:postBodyContent];
    VDFCacheObject *resultDiffUrlEndpoint = [self createTestCacheObjectWithUrl:@"some/url/different" httpMethod:HTTPMethodGET postBody:postBodyContent];
    VDFCacheObject *resultDiffHttpMethod = [self createTestCacheObjectWithUrl:@"some/url" httpMethod:HTTPMethodPOST postBody:postBodyContent];
    VDFCacheObject *resultDiffData = [self createTestCacheObjectWithUrl:@"some/url" httpMethod:HTTPMethodGET postBody:[@"some data" dataUsingEncoding:NSUTF8StringEncoding]];
    VDFCacheObject *result2 = [self createTestCacheObjectWithUrl:@"some/url" httpMethod:HTTPMethodGET postBody:postBodyContent];
    
    // assert
    XCTAssertEqualObjects(result1.cacheKey, result2.cacheKey, @"Cache key for the same requests should be the same.");
    XCTAssertNotEqualObjects(result1.cacheKey, resultDiffUrlEndpoint.cacheKey, @"Cache Key should be diffrent for different request parameters.");
    XCTAssertNotEqualObjects(result1.cacheKey, resultDiffHttpMethod.cacheKey, @"Cache Key should be diffrent for different request parameters.");
    XCTAssertNotEqualObjects(result1.cacheKey, resultDiffData.cacheKey, @"Cache Key should be diffrent for different request parameters.");
    XCTAssertNotEqualObjects(resultDiffUrlEndpoint.cacheKey, resultDiffHttpMethod.cacheKey, @"Cache Key should be diffrent for different request parameters.");
    XCTAssertNotEqualObjects(resultDiffUrlEndpoint.cacheKey, resultDiffData.cacheKey, @"Cache Key should be diffrent for different request parameters.");
    XCTAssertNotEqualObjects(resultDiffHttpMethod.cacheKey, resultDiffData.cacheKey, @"Cache Key should be diffrent for different request parameters.");
}


- (void)testCreateHttpConnectorRequest {
    
    // mock
    id mockDelegate =OCMProtocolMock(@protocol(VDFOAuthTokenRequestDelegate));
    NSData *postBodyContent = [NSData data];
    
    // stubs
    self.configuration.apixBaseUrl = @"http://someUrl.com/";
    self.configuration.defaultHttpConnectionTimeout = 100;
    [[[self.mockBuilder stub] andReturn:@"some/endpoint/method"] urlEndpointQuery];
    [[[self.mockBuilder stub] andReturnValue:OCMOCK_VALUE(HTTPMethodPOST)] httpRequestMethodType];
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
    // TODO IMPORTANT when it will be attached to production servers (not mockups) then uncomment this
//    XCTAssertEqualObjects(result.url, @"http://someUrl.com/some/endpoint/method", @"Url was not set proeprly.");
//    XCTAssertTrue(result.isGSMConnectionRequired, @"GSM Connection is required for this factory.");
}

- (void)testPostBodyCreationWithoutScopes {
    
    // mock
    VDFOAuthTokenRequestOptions *requestOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    requestOptions.clientId = @"someClientID";
    requestOptions.clientSecret = @"someClientSecret";
    
    // stub
    [[[self.mockBuilder stub] andReturn:requestOptions] requestOptions];
    
    // run
    NSData *result = [self.factoryToTestMock postBody];
    
    // assert
    XCTAssertEqualObjects([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding],
                          @"grant_type=client_credentials&client_id=someClientID&client_secret=someClientSecret",
                          @"Post body is generated not properly.");
}

- (void)testPostBodyCreationWithScopes {
    
    // mock
    VDFOAuthTokenRequestOptions *requestOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    requestOptions.clientId = @"someClientID";
    requestOptions.clientSecret = @"someClientSecret";
    requestOptions.scopes = @[@"scopeOne", @"scopeTwo"];
    
    // stub
    [[[self.mockBuilder stub] andReturn:requestOptions] requestOptions];
    
    // run
    NSData *result = [self.factoryToTestMock postBody];
    
    // assert
    XCTAssertEqualObjects([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding],
                          @"grant_type=client_credentials&client_id=someClientID&client_secret=someClientSecret&scope=scopeOne&scope=scopeTwo",
                          @"Post body is generated not properly.");
}

- (void)testPostBodyCreationWithOneScope {
    
    // mock
    VDFOAuthTokenRequestOptions *requestOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    requestOptions.clientId = @"someClientID";
    requestOptions.clientSecret = @"someClientSecret";
    requestOptions.scopes = @[@"scopeOne"];
    
    // stub
    [[[self.mockBuilder stub] andReturn:requestOptions] requestOptions];
    
    // run
    NSData *result = [self.factoryToTestMock postBody];
    
    // assert
    XCTAssertEqualObjects([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding],
                          @"grant_type=client_credentials&client_id=someClientID&client_secret=someClientSecret&scope=scopeOne",
                          @"Post body is generated not properly.");
}


#pragma mark -
#pragma mark - helper method
- (VDFCacheObject*)createTestCacheObjectWithUrl:(NSString*)url httpMethod:(HTTPMethodType)methodType postBody:(NSData*)body {
    
    // mock
    id localMockBuilder = OCMClassMock([VDFOAuthTokenRequestBuilder class]);
    id localFactoryToTest = [[VDFOAuthTokenRequestFactory alloc] initWithBuilder:localMockBuilder];
    id localMockactoryToTest = OCMPartialMock(localFactoryToTest);
    
    // stubs
    [[[localMockBuilder stub] andReturn:url] urlEndpointQuery];
    [[[localMockBuilder stub] andReturnValue:OCMOCK_VALUE(((HTTPMethodType)methodType))] httpRequestMethodType];
    [[[localMockactoryToTest stub] andReturn:body] postBody];
    
    // run
    return [localMockactoryToTest createCacheObject];
}


@end

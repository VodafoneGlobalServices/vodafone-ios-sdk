//
//  VDFSmsValidationRequestFactoryTestCase.m
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
#import "VDFSmsValidationRequestFactory.h"
#import "VDFSmsValidationRequestBuilder.h"
#import "VDFSmsValidationResponseParser.h"
#import "VDFSmsValidationRequestState.h"
#import "VDFBaseConfiguration.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFSettings.h"
#import "VDFDIContainer.h"

@interface VDFSmsValidationRequestFactory ()
- (NSData*)postBody;
@end

@interface VDFSmsValidationRequestFactoryTestCase : VDFFactoryBaseTestCase
@property VDFSmsValidationRequestFactory *factoryToTest;
@property id mockBuilder;
@property id factoryToTestMock;
@property VDFBaseConfiguration *configuration;
@end

@implementation VDFSmsValidationRequestFactoryTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockBuilder = OCMClassMock([VDFSmsValidationRequestBuilder class]);
    self.factoryToTest = [[VDFSmsValidationRequestFactory alloc] initWithBuilder:self.mockBuilder];
    self.factoryToTestMock = OCMPartialMock(self.factoryToTest);
    self.configuration = [[VDFBaseConfiguration alloc] init];
    
    id mockDIContainer = OCMClassMock([VDFDIContainer class]);
    [[[mockDIContainer stub] andReturn:self.configuration] resolveForClass:[VDFBaseConfiguration class]];
    
    // stubs
    [[[self.mockBuilder stub] andReturn:mockDIContainer] diContainer];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateResponseParser {
    [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                         selector: @selector(createResponseParser)
                              expectedResultClass: [VDFSmsValidationResponseParser class]];
}

- (void)testCreateRequestState {
    [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                         selector: @selector(createRequestState)
                              expectedResultClass: [VDFSmsValidationRequestState class]];
}

- (void)testCreateObserversContainer {
    VDFArrayObserversContainer *result = [super runAndAssertSimpleCreateMethodOnTarget: self.factoryToTest
                                                                              selector: @selector(createObserversContainer)
                                                                   expectedResultClass: [VDFArrayObserversContainer class]];
    
    XCTAssertEqual(result.notifySelector, @selector(didValidatedSMSToken:withError:), @"Selector set to observers container is invalid");
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
    NSData *postBodyContent = [NSData data];
    id mockOAuthToken = OCMClassMock([VDFOAuthTokenResponse class]);
    
    // stubs
    self.configuration.apixBaseUrl = @"http://someUrl.com/";
    self.configuration.defaultHttpConnectionTimeout = 100;
    [[[self.mockBuilder stub] andReturn:@"some/endpoint/method"] urlEndpointQuery];
    [[[self.mockBuilder stub] andReturnValue:OCMOCK_VALUE(HTTPMethodPOST)] httpRequestMethodType];
    [[[self.factoryToTestMock stub] andReturn:postBodyContent] postBody];
    [[[self.mockBuilder stub] andReturn:mockOAuthToken] oAuthToken];
    [[[mockOAuthToken stub] andReturn:@"Barier"] tokenType];
    [[[mockOAuthToken stub] andReturn:@"asd"] accessToken];
    [[[self.mockBuilder stub] andReturn:@"appID"] applicationId];
    
    // run
    VDFHttpConnector *result = [self.factoryToTestMock createHttpConnectorRequestWithDelegate:mockDelegate];
    
    // assert
    XCTAssertEqualObjects(result.delegate, mockDelegate, @"Delegate object was not proeprly set on Http connector object.");
    XCTAssertEqual(result.connectionTimeout, (NSTimeInterval)100, @"Default connection time out from configuration was not set.");
    XCTAssertEqual(result.methodType, HTTPMethodPOST, @"Http method type was not set from builder.");
    XCTAssertFalse(result.isGSMConnectionRequired, @"GSM Connection is not required for this factory.");
    XCTAssertEqualObjects(result.postBody, postBodyContent, @"Post Body was not set proeprly.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"Content-Type"], @"application/json", @"Content-Type header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"Authorization"], @"Barier asd", @"Authorization header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"User-Agent"], [VDFSettings sdkVersion], @"User-Agent header was not set.");
    XCTAssertEqualObjects([result.requestHeaders objectForKey:@"Application-ID"], @"appID", @"User-Agent header was not set.");
    XCTAssertEqualObjects(result.url, @"http://someUrl.com/some/endpoint/method", @"Url was not set proeprly.");
}

- (void)testPostBodyCreation {
    
    // stub
    [[[self.mockBuilder stub] andReturn:@"smsCodeTest"] smsCode];
    
    // run
    NSData *result = [self.factoryToTestMock postBody];
    
    // assert
    XCTAssertEqualObjects([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding], @"{ \"PINCode\" : \"smsCodeTest\" }", @"Post body is generated not properly.");
}


@end

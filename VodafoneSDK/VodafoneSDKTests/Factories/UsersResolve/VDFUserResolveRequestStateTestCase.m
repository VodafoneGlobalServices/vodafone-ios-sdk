//
//  VDFUserResolveRequestStateTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUserResolveRequestState.h"
#import "VDFUserResolveRequestBuilder.h"
#import "VDFUserResolveOptions.h"
#import "VDFUserTokenDetails.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFConsts.h"
#import "VDFError.h"

extern void __gcov_flush();

@interface VDFUserResolveRequestState ()
@property BOOL needRetry;
@property NSTimeInterval retryAfterMiliseconds;
@property (nonatomic, strong) NSError *error;

- (void)readEtagFromResponse:(VDFHttpConnectorResponse*)response;
- (void)readErrorFromResponse:(VDFHttpConnectorResponse*)response;
@end

@interface VDFUserResolveRequestStateTestCase : XCTestCase
@property VDFUserResolveRequestState *requestStateToTest;
@property id requestStateToTestMock;
@property id mockBuilder;

- (void)assertForInitialState;
@end

@implementation VDFUserResolveRequestStateTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockBuilder = OCMClassMock([VDFUserResolveRequestBuilder class]);
    self.requestStateToTest = [[VDFUserResolveRequestState alloc] initWithBuilder:self.mockBuilder];
    self.requestStateToTestMock = OCMPartialMock(self.requestStateToTest);
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testReadEtagFromResponse {
    
    // mock
    id etag = @"someExampleETagValue";
    id responseMockWithoutHeaders = OCMClassMock([VDFHttpConnectorResponse class]);
    id responseMockWithoutEtag = OCMClassMock([VDFHttpConnectorResponse class]);
    id responseMockWithEtag = OCMClassMock([VDFHttpConnectorResponse class]);
    self.requestStateToTest.needRetry = YES;
    
    // stub
    [[[responseMockWithoutHeaders stub] andReturn:nil] responseHeaders];
    [[[responseMockWithoutEtag stub] andReturn:@{ @"some header" : @"some value" }] responseHeaders];
    [[[responseMockWithEtag stub] andReturn:@{ HTTP_HEADER_ETAG : etag }] responseHeaders];
    
    // expect that the builder will get at first initial etag value:
    [[self.mockBuilder expect] setETag:CHECK_STATUS_ETAG_INITIAL_VALUE];
    // run
    [self.requestStateToTest readEtagFromResponse:responseMockWithoutHeaders];
    // verify
    [self.mockBuilder verify];
    
    
    // expect that next etag will be set to proper value:
    [[self.mockBuilder expect] setETag:etag];
    // run
    [self.requestStateToTest readEtagFromResponse:responseMockWithEtag];
    // verify
    [self.mockBuilder verify];
    
    
    // test when do not need retry:
    // stub
    self.requestStateToTest.needRetry = NO;
    // expect that this method will be not call more than twice
    [[self.mockBuilder reject] setETag:[OCMArg any]];
    // run
    [self.requestStateToTest readEtagFromResponse:responseMockWithoutEtag];
    // verify
    [self.mockBuilder verify];
    
    
    // test when etag alread initialized
    // stub
    self.requestStateToTest.needRetry = YES;
    [[[self.mockBuilder stub] andReturn:@"some etag"] eTag];
    // expect that this method will be not call more than twice
    [[self.mockBuilder reject] setETag:[OCMArg any]];
    // run
    [self.requestStateToTest readEtagFromResponse:responseMockWithoutEtag];
    // verify
    [self.mockBuilder verify];
}


- (void)testReadErrorFromResponse{
    
    // mock
    VDFHttpConnectorResponse *mockResponse = [[VDFHttpConnectorResponse alloc] init];
    
    // stub & run
    mockResponse.httpResponseCode = 201; // created - from resolve
    [self.requestStateToTest readErrorFromResponse:mockResponse];
    // stub & run
    mockResponse.httpResponseCode = 200; // ok - from check status
    [self.requestStateToTest readErrorFromResponse:mockResponse];
    // stub & run
    mockResponse.httpResponseCode = 302; // redirect
    [self.requestStateToTest readErrorFromResponse:mockResponse];
    // stub & run
    mockResponse.httpResponseCode = 304; // redirect
    [self.requestStateToTest readErrorFromResponse:mockResponse];
    // stub & run
    mockResponse.httpResponseCode = 404; // Not found - Token expired - from check status
    [self.requestStateToTest readErrorFromResponse:mockResponse];
    
    // assert for valid respones
    XCTAssertNil(self.requestStateToTest.error, @"Error should not be set");
    
    // stub & run & assert
    mockResponse.httpResponseCode = 400; // invalid input
    [self.requestStateToTest readErrorFromResponse:mockResponse];
    XCTAssertEqual([self.requestStateToTest.error code], VDFErrorInvalidInput, @"Error code is invalid");
    XCTAssertEqualObjects([self.requestStateToTest.error domain], VodafoneErrorDomain, @"Error domain is invalid");
    
    // stub & run & assert
    mockResponse.httpResponseCode = 500; // some other error always server communication
    [self.requestStateToTest readErrorFromResponse:mockResponse];
    XCTAssertEqual([self.requestStateToTest.error code], VDFErrorServerCommunication, @"Error code is invalid");
    XCTAssertEqualObjects([self.requestStateToTest.error domain], VodafoneErrorDomain, @"Error domain is invalid");
}


- (void)testInitialState {
    [self assertForInitialState];
}

- (void)testUpdateWithWrongHttpResponse {
    
    // run
    [self.requestStateToTest updateWithHttpResponse:nil];
    
    // assert
    [self assertForInitialState];
}

- (void)testUpdateWitValidHttpResponse {
    
    // mock
    id etag = @"someExampleETagValue";
    id responseMockWithRedirect = OCMClassMock([VDFHttpConnectorResponse class]);
    id responseMockWithNotModified = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseMockWithRedirect stub] andReturn:@{ HTTP_HEADER_ETAG : etag }] responseHeaders];
    [[[responseMockWithRedirect stub] andReturnValue:@302] httpResponseCode];
    [[[responseMockWithNotModified stub] andReturnValue:@304] httpResponseCode];
    
    // expect that the etag will be readed:
    [[self.requestStateToTestMock expect] readEtagFromResponse:responseMockWithRedirect];
    [[self.requestStateToTestMock expect] readEtagFromResponse:responseMockWithNotModified];
    
    // expect that the error will be readed:
    [[self.requestStateToTestMock expect] readErrorFromResponse:responseMockWithRedirect];
    [[self.requestStateToTestMock expect] readErrorFromResponse:responseMockWithNotModified];
    
    // run
    [self.requestStateToTestMock updateWithHttpResponse:responseMockWithRedirect];
    [self.requestStateToTestMock updateWithHttpResponse:responseMockWithNotModified];
    
    // verify
    [self.requestStateToTestMock verify];
    [self assertForInitialState]; // state should not change in this case
}

- (void)testUpdateSessionTokenWithParsedObject {
    
    // mock
    NSString *sessionToken = @"mockSessionToken";
    id responseWithSessionToken = OCMClassMock([VDFUserTokenDetails class]);
    id responseWithoutSessionToken = OCMClassMock([VDFUserTokenDetails class]);
    
    // stub
    [[[responseWithSessionToken stub] andReturn:sessionToken] token];
    [[[responseWithoutSessionToken stub] andReturn:nil] token];
    
    // expect that the session token will be passed to the builder only once
    [[self.mockBuilder expect] setSessionToken:sessionToken];
    [[self.mockBuilder reject] setSessionToken:[OCMArg any]];
    
    // run
    [self.requestStateToTest updateWithParsedResponse:responseWithSessionToken];
    [self.requestStateToTest updateWithParsedResponse:responseWithoutSessionToken];
    
    // assert & verify
    [self.mockBuilder verify];
    XCTAssertTrue([[self.requestStateToTest lastResponseExpirationDate] compare:[NSDate date]] == NSOrderedAscending, @"UserResolve request should have date previus than current because it is not cached.");
    
}

- (void)testUpdateWithInvalidParsedObject {
    
    // run & assert
    [self.requestStateToTest updateWithParsedResponse:nil];
    [self assertForInitialState];
    
    // run & assert
    [self.requestStateToTest updateWithParsedResponse:@"fakeMock"];
    [self assertForInitialState];
}

- (void)assertForInitialState {
    XCTAssertTrue([self.requestStateToTest isRetryNeeded], @"Initial state of userResolve request as defaults need to retry.");
    XCTAssertTrue([[self.requestStateToTest lastResponseExpirationDate] compare:[NSDate date]] == NSOrderedAscending, @"UserResolve request should have date previus than current because it is not cached.");
    XCTAssertNil([self.requestStateToTest responseError], @"Initial state of userResolve request as defaults has no error.");
}

@end

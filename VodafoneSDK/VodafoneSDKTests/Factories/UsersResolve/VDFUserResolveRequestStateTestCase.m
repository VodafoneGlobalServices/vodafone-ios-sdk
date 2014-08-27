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

extern void __gcov_flush();

@interface VDFUserResolveRequestState ()
@property BOOL needRetry;
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

- (void)testInitialState {
    [self assertForInitialState];
}

- (void)testUpdateWithWrongHttpResponse {
    
    // mock
    id responseMock = OCMClassMock([VDFHttpConnectorResponse class]);
    id responseMockWithHeaders = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseMock stub] andReturn:[NSData data]] data];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    [[[responseMock stub] andReturn:nil] responseHeaders];
    [[[responseMockWithHeaders stub] andReturn:[NSData data]] data];
    [[[responseMockWithHeaders stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    [[[responseMockWithHeaders stub] andReturn:@{ @"someHeaderInvalid" : @"invalidValue" }] responseHeaders];
    
    // run & assert
    [self.requestStateToTest updateWithHttpResponse:responseMock];
    [self assertForInitialState];
    
    // run & assert
    [self.requestStateToTest updateWithHttpResponse:responseMockWithHeaders];
    [self assertForInitialState];
    
    // run & assert
    [self.requestStateToTest updateWithHttpResponse:nil];
    [self assertForInitialState];
}

- (void)testUpdateWitHttpResponseWithETag {
    
    // mock
    id etag = @"someExampleETagValue";
    id responseMock = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseMock stub] andReturn:@{ @"Etag" : etag }] responseHeaders];
    
    // expect that the builder will get info about etag
    [[self.mockBuilder expect] setETag:etag];
    
    // run
    [self.requestStateToTest updateWithHttpResponse:responseMock];
    
    // verify
    [self.mockBuilder verify];
    [self assertForInitialState]; // state should not change
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

- (void)testUpdateRetryFlagWithParsedObjectWhenNeedRetry {
    
    // mock
    id responseStillRunning = OCMClassMock([VDFUserTokenDetails class]);
    id responseFinished = OCMClassMock([VDFUserTokenDetails class]);
    
    // stub
    self.requestStateToTest.needRetry = YES;
    [[[responseStillRunning stub] andReturnValue:OCMOCK_VALUE(YES)] stillRunning];
    [[[responseFinished stub] andReturnValue:OCMOCK_VALUE(NO)] stillRunning];
    
    // run & assert
    [self.requestStateToTestMock updateWithParsedResponse:responseStillRunning];
    XCTAssertTrue([self.requestStateToTest isRetryNeeded], @"UserResolve request should change state of retrying.");
    
    // run & assert
    [self.requestStateToTestMock updateWithParsedResponse:responseFinished];
    XCTAssertFalse([self.requestStateToTest isRetryNeeded], @"UserResolve request should change state of retrying.");
    
    // assert
    XCTAssertTrue([[self.requestStateToTest lastResponseExpirationDate] compare:[NSDate date]] == NSOrderedAscending, @"UserResolve request should have date previus than current because it is not cached.");
}

- (void)testUpdateRetryFlagWithParsedObjectWhenNotNeedRetry {
    
    // mock
    id responseStillRunning = OCMClassMock([VDFUserTokenDetails class]);
    id responseFinished = OCMClassMock([VDFUserTokenDetails class]);
    
    // stub
    self.requestStateToTest.needRetry = NO;
    [[[responseStillRunning stub] andReturnValue:OCMOCK_VALUE(YES)] stillRunning];
    [[[responseFinished stub] andReturnValue:OCMOCK_VALUE(NO)] stillRunning];
    
    // run & assert
    [self.requestStateToTestMock updateWithParsedResponse:responseStillRunning];
    XCTAssertFalse([self.requestStateToTest isRetryNeeded], @"UserResolve request when not need to retry should not change state of retrying.");
    
    // run & assert
    [self.requestStateToTestMock updateWithParsedResponse:responseFinished];
    XCTAssertFalse([self.requestStateToTest isRetryNeeded], @"UserResolve request when not need to retry should not change state of retrying.");
    
    // assert
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
}

@end

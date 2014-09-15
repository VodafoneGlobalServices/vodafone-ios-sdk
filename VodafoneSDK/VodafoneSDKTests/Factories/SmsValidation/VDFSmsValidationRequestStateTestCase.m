//
//  VDFSmsValidationRequestStateTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 27/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFSmsValidationRequestState.h"
#import "VDFHttpConnectorResponse.h"

extern void __gcov_flush();

@interface VDFSmsValidationRequestStateTestCase : XCTestCase
@property VDFSmsValidationRequestState *requestStateToTest;

- (void)assertForInitialState;
@end

@implementation VDFSmsValidationRequestStateTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.requestStateToTest = [[VDFSmsValidationRequestState alloc] init];
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

- (void)testUpdateWithHttpResponse {
    
    // mock
    id responseMock = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseMock stub] andReturn:[NSData data]] data];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    
    // run & assert
    [self.requestStateToTest updateWithHttpResponse:responseMock];
    [self assertForInitialState];
    
    // run & assert
    [self.requestStateToTest updateWithHttpResponse:nil];
    [self assertForInitialState];
}

- (void)testUpdateWithParsedResponse {
    
    // run & assert
    [self.requestStateToTest updateWithParsedResponse:nil];
    [self assertForInitialState];
    
    // run & assert
    [self.requestStateToTest updateWithParsedResponse:@"fakeMock"];
    [self assertForInitialState];
    
    // run & assert
    [self.requestStateToTest updateWithParsedResponse:@YES];
    [self assertForInitialState];
    
}


- (void)assertForInitialState {
    XCTAssertFalse([self.requestStateToTest isRetryNeeded], @"Initial state of sms validation request as defaults do not need to retry.");
    XCTAssertTrue([[self.requestStateToTest lastResponseExpirationDate] compare:[NSDate date]] == NSOrderedAscending, @"Sms validation request should have date previus than current because it is not cached.");
    XCTAssertNil([self.requestStateToTest responseError], @"Initial state of sms validation request as defaults has no error.");
}

@end

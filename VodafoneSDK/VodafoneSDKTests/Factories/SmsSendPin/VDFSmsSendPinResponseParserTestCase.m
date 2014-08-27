//
//  VDFSmsSendPinResponseParserTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 26/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFSmsSendPinResponseParser.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFResponseParserBaseTestCase.h"

@interface VDFSmsSendPinResponseParserTestCase : VDFResponseParserBaseTestCase
@property VDFSmsSendPinResponseParser *parserToTest;
@end

@implementation VDFSmsSendPinResponseParserTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.parserToTest = [[VDFSmsSendPinResponseParser alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseValidData {
    
    // mock
    id responseSuccessMock = OCMClassMock([VDFHttpConnectorResponse class]);
    id responseFailedMock = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseSuccessMock stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    [[[responseFailedMock stub] andReturnValue:OCMOCK_VALUE(309)] httpResponseCode];
    
    // run
    id successResult = [self.parserToTest parseResponse:responseSuccessMock];
    id failedResult = [self.parserToTest parseResponse:responseFailedMock];
    
    XCTAssertTrue([successResult isKindOfClass:[NSNumber class]], @"Success result is in invalid type");
    XCTAssertTrue([failedResult isKindOfClass:[NSNumber class]], @"Failed result is in invalid type");
    XCTAssertTrue([successResult boolValue], @"Success result holds failed result");
    XCTAssertFalse([failedResult boolValue], @"Failed result holds success result");
}

- (void)testParseInvalidResponse {
    // run & assert
    XCTAssertNil([self.parserToTest parseResponse:nil], @"Nil response should parse to nil.");
}


@end

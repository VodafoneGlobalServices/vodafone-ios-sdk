//
//  VDFSmsValidationResponseParserTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 27/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFResponseParserBaseTestCase.h"
#import "VDFSmsValidationResponseParser.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFSmsValidationResponse.h"

@interface VDFSmsValidationResponseParserTestCase : VDFResponseParserBaseTestCase
@property VDFSmsValidationResponseParser *parserToTest;
@property NSString *smsCode;
@end

@implementation VDFSmsValidationResponseParserTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.smsCode = @"fakeSmsCode";
    self.parserToTest = [[VDFSmsValidationResponseParser alloc] initWithRequestSmsCode:self.smsCode];
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
    
    XCTAssertTrue([successResult isKindOfClass:[VDFSmsValidationResponse class]], @"Success result is in invalid type");
    XCTAssertTrue([failedResult isKindOfClass:[VDFSmsValidationResponse class]], @"Failed result is in invalid type");
    XCTAssertEqualObjects(((VDFSmsValidationResponse*)successResult).smsCode, self.smsCode, @"Sms code is invalid in success result.");
    XCTAssertEqualObjects(((VDFSmsValidationResponse*)failedResult).smsCode, self.smsCode, @"Sms code is invalid in failure result.");
    XCTAssertTrue(((VDFSmsValidationResponse*)successResult).isSucceded, @"Succeded flag is invalid in success result.");
    XCTAssertFalse(((VDFSmsValidationResponse*)failedResult).isSucceded, @"Succeded flag is invalid in failure result.");
}

- (void)testParseInvalidResponse {
    // run & assert
    XCTAssertNil([self.parserToTest parseResponse:nil], @"Nil response should parse to nil.");
}

@end

//
//  VDFUserResolveResponseParserTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUserResolveResponseParser.h"
#import "VDFUserTokenDetails.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFResponseParserBaseTestCase.h"

@interface VDFUserResolveResponseParserTestCase : VDFResponseParserBaseTestCase
@property VDFUserResolveResponseParser *parserToTest;
@end

@implementation VDFUserResolveResponseParserTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.parserToTest = [[VDFUserResolveResponseParser alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// TODO implement parser unit tests

/*
- (void)testParseValidData {
    
    // mock
    NSData *sampleJsonData = [@"{\"resolved\":true,\"stillRunning\":true,\"token\":\"71660abbd4cfb8cc57eb4c97fbe4d164\",\"validationRequired\":true}" dataUsingEncoding:NSUTF8StringEncoding];
    id responseMock = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseMock stub] andReturn:sampleJsonData] data];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    
    // run & assert
    XCTAssertNotNil([self.parserToTest parseResponse:responseMock], @"Proper json response should parse to object.");
}
 */

- (void)testParseInvalidResponse {
    // run & assert
    XCTAssertNil([self.parserToTest parseResponse:nil], @"Nil response should parse to nil.");
    [super runAndExpectNilResultOnParser:self.parserToTest dataFromString:nil responseCode:200 messagePrefix:@"Response with invalid data"];
    [super runAndExpectNilResultOnParser:self.parserToTest dataFromString:@"" responseCode:501 messagePrefix:@"Response with invalid response code"];
    [super runAndExpectNilResultOnParser:self.parserToTest dataFromString:@"dfgdfg dfg" responseCode:200 messagePrefix:@"Response with invalid data structure"];
}


@end

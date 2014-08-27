//
//  VDFOAuthTokenResponseParserTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 26/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFOAuthTokenResponseParser.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFResponseParserBaseTestCase.h"

@interface VDFOAuthTokenResponseParserTestCase : VDFResponseParserBaseTestCase
@property VDFOAuthTokenResponseParser *parserToTest;
@end

@implementation VDFOAuthTokenResponseParserTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.parserToTest = [[VDFOAuthTokenResponseParser alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseValidData {
    
    // mock
    NSData *data = [@"{ \"access_token\" : \"sdfdsf\", \"token_type\" : \"Barier\", \"expires_in\" : 12345 }" dataUsingEncoding:NSUTF8StringEncoding];
    id responseMock = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseMock stub] andReturn:data] data];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    
    // run & assert
    XCTAssertNotNil([self.parserToTest parseResponse:responseMock], @"Proper json response should parse to object.");
}

- (void)testParseInvalidResponse {
    // run & assert
    XCTAssertNil([self.parserToTest parseResponse:nil], @"Nil response should parse to nil.");
    [super runAndExpectNilResultOnParser:self.parserToTest dataFromString:nil responseCode:200 messagePrefix:@"Response with invalid data"];
    [super runAndExpectNilResultOnParser:self.parserToTest dataFromString:@"" responseCode:501 messagePrefix:@"Response with invalid response code"];
    [super runAndExpectNilResultOnParser:self.parserToTest dataFromString:@"dfgdfg dfg" responseCode:200 messagePrefix:@"Response with invalid data structure"];
}


@end

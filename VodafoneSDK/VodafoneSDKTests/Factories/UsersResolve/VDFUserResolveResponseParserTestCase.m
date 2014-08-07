//
//  VDFUserResolveResponseParserTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFUserResolveResponseParser.h"
#import "VDFUserTokenDetails.h"

extern void __gcov_flush();

@interface VDFUserResolveResponseParserTestCase : XCTestCase

- (void)assertTokenDetails:(VDFUserTokenDetails*)details withResolved:(BOOL)resolved stillRunning:(BOOL)stillRunning
                    source:(NSString*)source token:(NSString*)token expires:(NSDate*)expires
         tetheringConflict:(BOOL)tetheringConflict validated:(BOOL)validated;

@end

@implementation VDFUserResolveResponseParserTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsProperResponseParsedCorrectly
{
    id parserToTest = [[VDFUserResolveResponseParser alloc] init];
    
    NSData *sampleJsonData = [@"{\"resolved\":true,\"stillRunning\":true,\"source\":\"header\",\"token\":\"71660abbd4cfb8cc57eb4c97fbe4d164\",\"expires\":\"2014-08-08T12:57:32+02:00\",\"tetheringConflict\":false,\"validated\":true}" dataUsingEncoding:NSUTF8StringEncoding];
    
    VDFUserTokenDetails *parsedJson = (VDFUserTokenDetails*)[parserToTest parseData:sampleJsonData withHttpResponseCode:0];

    [self assertTokenDetails:parsedJson withResolved:true stillRunning:true source:@"header" token:@"71660abbd4cfb8cc57eb4c97fbe4d164" expires:[NSDate dateWithTimeIntervalSince1970:1407495452] tetheringConflict:NO validated:YES];
}

- (void)testInvalidJsonParsing
{
    id parserToTest = [[VDFUserResolveResponseParser alloc] init];
    
    id invalidJsons = @{@"Not json should parse to nil" : [@"error 2234" dataUsingEncoding:NSUTF8StringEncoding],
                        @"Empty string should parse to nil" : [@"" dataUsingEncoding:NSUTF8StringEncoding],
                        @"Invalid json should parse to nil" : [@"{some invalid json}" dataUsingEncoding:NSUTF8StringEncoding],
                        @"Json without varaiables from model should parse to nil" : [@"{some: \"json\", with: \"diffrent\", values:false}" dataUsingEncoding:NSUTF8StringEncoding],
                        @"Json without even one variable from model should parse to nil" : [@"{\"resolved\":true,\"stillRunning\":true,\"source\":\"header\",\"token\":\"71660abbd4cfb8cc57eb4c97fbe4d164\",\"expires\":\"2014-08-08T12:57:32+02:00\",\"tetheringConflict\":false}" dataUsingEncoding:NSUTF8StringEncoding]};
    
    for (NSString * key in [invalidJsons allKeys]) {
        VDFUserTokenDetails *parsedJson = (VDFUserTokenDetails*)[parserToTest parseData:[invalidJsons objectForKey:key] withHttpResponseCode:0];
        
        XCTAssertNil(parsedJson, @"%@", key);
    }
    
    // check also nil:
    VDFUserTokenDetails *parsedJson = (VDFUserTokenDetails*)[parserToTest parseData:nil withHttpResponseCode:0];
    
    XCTAssertNil(parsedJson, @"Nil string should parse to nil");
}


- (void)assertTokenDetails:(VDFUserTokenDetails*)details withResolved:(BOOL)resolved stillRunning:(BOOL)stillRunning
                    source:(NSString*)source token:(NSString*)token expires:(NSDate*)expires
         tetheringConflict:(BOOL)tetheringConflict validated:(BOOL)validated {
    
    XCTAssertNotNil(details, @"Proper json do not can be parsed to nil.");
    XCTAssertEqualObjects(details.source, source, "The source parsed incorrectly.");
    XCTAssertEqualObjects(details.token, token, "The token parsed incorrectly.");
    XCTAssertEqualObjects(details.expires, expires, "The expires parsed incorrectly.");
    XCTAssertEqual(details.resolved, resolved, "The resolved parsed incorrectly.");
    XCTAssertEqual(details.stillRunning, stillRunning, "The stillRunning parsed incorrectly.");
    XCTAssertEqual(details.tetheringConflict, tetheringConflict, "The tetheringConflict parsed incorrectly.");
    XCTAssertEqual(details.validated, validated, "The validated parsed incorrectly.");
}

@end

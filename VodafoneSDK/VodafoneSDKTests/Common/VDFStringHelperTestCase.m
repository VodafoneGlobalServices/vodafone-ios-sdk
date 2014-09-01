//
//  VDFStringHelperTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFStringHelper.h"

extern void __gcov_flush();

@interface VDFStringHelperTestCase : XCTestCase {
@private
    NSArray *md5HashesTestCases;
}

@end

@implementation VDFStringHelperTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    md5HashesTestCases = @[
                           @[ @"qwertyuiopasdfghjklzxcvbnm[];',./=-0987654321§£!@#$%^&*()_+}{POIUYTREWQASDFGHJKL:|?><MNBVCXZ~` ", @"D88C043B984404D20C5FC414092D91F4", @"MD5 of complicated string is wrong"],
                           @[ @"", @"d41d8cd98f00b204e9800998ecf8427e", @"MD5 from empty string is wrong" ],
                           @[ @"fsgsdgsdfwefsef", @"27d67ffe4ae4014dc5108a333baf5f6e", @"MD5 generated from simple string is wrong" ],
                           @[ @" ", @"7215EE9C7D9DC229D2921A40E899EC5F", @"MD5 of white space is wrong" ],
                           @[ @"\n", @"68B329DA9893E34099C7D8AD5CB9C940", @"MD5 of new line is wrong" ],
                           @[ @"\t", @"5E732A1878BE2342DBFEFF5FE3CA5AA3", @"MD5 of tabulator is wrong" ]
                           ];
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsURLEncodingProperly
{
    NSString *stringToEncode = @"qwertyuiopasdfghjklzxcvbnm[];'\\\\,./=-0987654321§£!@#$%^&*()_+}{POIUYTREWQASDFGHJKL:\\\"|?><MNBVCXZ~` ";
    NSString *properResult = @"qwertyuiopasdfghjklzxcvbnm%5B%5D%3B%27%5C%5C%2C.%2F%3D-0987654321%C2%A7%C2%A3%21%40%23%24%25%5E%26%2A%28%29_%2B%7D%7BPOIUYTREWQASDFGHJKL%3A%5C%22%7C%3F%3E%3CMNBVCXZ~%60%20";
    
    XCTAssertEqualObjects([VDFStringHelper urlEncode:stringToEncode], properResult, @"URL is encoded wrong");
    XCTAssertEqualObjects([VDFStringHelper urlEncode:@""], @"", @"Empty URL is encoded wrong");
}

- (void)testIsMD5FromStringGeneratedProperly
{
    for (NSArray *testCase in md5HashesTestCases) {
        NSString *md5Hash = [[VDFStringHelper md5FromString:[testCase objectAtIndex:0]] uppercaseString];
        NSString *properResult = [[testCase objectAtIndex:1] uppercaseString];
        NSString *errorMessage = [testCase objectAtIndex:2];
        XCTAssertEqualObjects(md5Hash, properResult, @"%@", errorMessage);
    }
}

- (void)testIsMD5FromNSDataGeneratedProperly
{
    for (NSArray *testCase in md5HashesTestCases) {
        NSString *md5Hash = [[VDFStringHelper md5FromData:[[testCase objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding]] uppercaseString];
        NSString *properResult = [[testCase objectAtIndex:1] uppercaseString];
        NSString *errorMessage = [testCase objectAtIndex:2];
        XCTAssertEqualObjects(md5Hash, properResult, @"%@", errorMessage);
    }
}


- (void)testIsRandomStringGeneratingProperly {
    
    // run
    NSString *randomString1 = [VDFStringHelper randomString];
    NSString *randomString2 = [VDFStringHelper randomString];
    
    // assert
    XCTAssertNotEqualObjects(randomString1, randomString2, @"Random string is not generating properly.");
}

@end

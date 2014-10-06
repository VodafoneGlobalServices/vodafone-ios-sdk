//
//  VDFDeviceUtilityTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 27/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFDeviceUtility.h"

extern void __gcov_flush();

@interface VDFDeviceUtilityTestCase : XCTestCase

@end

@implementation VDFDeviceUtilityTestCase

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


- (void)testIsDeviceIDGeneratedSameAlways {
    
    VDFDeviceUtility *utility1 = [[VDFDeviceUtility alloc] init];
    VDFDeviceUtility *utility2 = [[VDFDeviceUtility alloc] init];
    
    // run
    NSString *firstResult = [utility1 deviceUniqueIdentifier];
    NSString *secondResult = [utility2 deviceUniqueIdentifier];
    
    XCTAssertEqualObjects(firstResult, secondResult, @"Each call to unique device should be the same");
}

- (void)testIsSimMCCSameAlways {
    
    // run
    NSString *firstResult = [VDFDeviceUtility simMCC];
    NSString *secondResult = [VDFDeviceUtility simMCC];
    
    XCTAssertEqualObjects(firstResult, secondResult, @"Each call to simMCC should be the same");
}

@end

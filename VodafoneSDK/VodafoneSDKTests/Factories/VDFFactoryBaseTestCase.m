//
//  VDFFactoryBaseTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFFactoryBaseTestCase.h"
#import <XCTest/XCTest.h>

extern void __gcov_flush();

@implementation VDFFactoryBaseTestCase

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


- (id)runAndAssertSimpleCreateMethodOnTarget:(id)target selector:(SEL)selector expectedResultClass:(Class)expectedResultClass {
    
    // run & assert:
    id result;
    XCTAssertNoThrow(result = [target performSelector:selector], @"Create method (of %@ object) should not throw exceptions.", expectedResultClass);
    XCTAssertNotNil(result, @"Create method (of %@ object) should not return nil.", expectedResultClass);
    XCTAssertEqual([result class], expectedResultClass, @"Create method (of %@ object) not returned expected type of object..", expectedResultClass);
    
    return result;
}


@end

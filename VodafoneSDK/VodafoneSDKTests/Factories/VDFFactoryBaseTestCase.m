//
//  VDFFactoryBaseTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFFactoryBaseTestCase.h"
#import <XCTest/XCTest.h>

@implementation VDFFactoryBaseTestCase


- (id)runAndAssertSimpleCreateMethodOnTarget:(id)target selector:(SEL)selector expectedResultClass:(Class)expectedResultClass {
    
    // run & assert:
    id result;
    XCTAssertNoThrow(result = ((id (*)(id, SEL))[target methodForSelector:selector])(target, selector), @"Create method (of %@ object) should not throw exceptions.", expectedResultClass);
    XCTAssertNotNil(result, @"Create method (of %@ object) should not return nil.", expectedResultClass);
    XCTAssertEqual([result class], expectedResultClass, @"Create method (of %@ object) not returned expected type of object..", expectedResultClass);
    
    return result;
}

@end

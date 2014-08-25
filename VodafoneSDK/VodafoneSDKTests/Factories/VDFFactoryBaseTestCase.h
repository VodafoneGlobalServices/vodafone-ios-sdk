//
//  VDFFactoryBaseTestCase.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface VDFFactoryBaseTestCase : XCTestCase

- (id)runAndAssertSimpleCreateMethodOnTarget:(id)target selector:(SEL)selector expectedResultClass:(Class)expectedResultClass;

@end

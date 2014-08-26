//
//  VDFRequestBaseFactoryTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 26/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFFactoryBaseTestCase.h"
#import "VDFArrayObserversContainer.h"
#import "VDFRequestBaseFactory.h"

@interface VDFRequestBaseFactoryTestCase : VDFFactoryBaseTestCase

@end

@implementation VDFRequestBaseFactoryTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testObserversCreation {
    VDFRequestBaseFactory *factory = [[VDFRequestBaseFactory alloc] init];
    
    VDFArrayObserversContainer *result = [super runAndAssertSimpleCreateMethodOnTarget: factory
                                                                              selector: @selector(createObserversContainer)
                                                                   expectedResultClass: [VDFArrayObserversContainer class]];
    
    XCTAssertTrue(result.notifySelector == NULL, @"Selector set to observers should be NULL.");
}

@end

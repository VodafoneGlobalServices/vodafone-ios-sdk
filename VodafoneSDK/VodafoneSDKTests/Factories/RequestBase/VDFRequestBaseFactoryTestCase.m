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


- (void)testObserversCreation {
    VDFRequestBaseFactory *factory = [[VDFRequestBaseFactory alloc] init];
    
    VDFArrayObserversContainer *result = [super runAndAssertSimpleCreateMethodOnTarget: factory
                                                                              selector: @selector(createObserversContainer)
                                                                   expectedResultClass: [VDFArrayObserversContainer class]];
    
    XCTAssertTrue(result.notifySelector == NULL, @"Selector set to observers should be NULL.");
}

- (void)test_isAbstractMethodsThrowsException {
    VDFRequestBaseFactory *factory = [[VDFRequestBaseFactory alloc] init];
    
    XCTAssertThrows([factory createHttpConnectorRequestWithDelegate:nil], @"Abstract method should throw error.");
    XCTAssertThrows([factory createCacheObject], @"Abstract method should throw error.");
    XCTAssertThrows([factory createResponseParser], @"Abstract method should throw error.");
    XCTAssertThrows([factory createRequestState], @"Abstract method should throw error.");
}


@end

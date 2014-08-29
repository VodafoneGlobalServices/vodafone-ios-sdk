//
//  VDFDIContainerTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFDIContainer.h"

extern void __gcov_flush();

@protocol TestProtocol <NSObject>

@end

@interface VDFDIContainerTestCase : XCTestCase
@property VDFDIContainer *diContainerToTest;
@end

@implementation VDFDIContainerTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.diContainerToTest = [[VDFDIContainer alloc] init];
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegisteringInstanceForClass {
    
    // mock
    id instance = @"someInstance";
    id secondInstance = @"someSecondInstance";
    
    // run & assert - added
    [self.diContainerToTest registerInstance:instance forClass:[NSString class]];
    XCTAssertEqual([self.diContainerToTest resolveForClass:[NSString class]], instance, @"Registered instance by class was wrong resolved after adding");
    
    // run & assert - changed
    [self.diContainerToTest registerInstance:secondInstance forClass:[NSString class]];
    XCTAssertEqual([self.diContainerToTest resolveForClass:[NSString class]], secondInstance, @"Registered instance by class was wrong resolved after changing");
    
    // run & assert -- removed
    [self.diContainerToTest registerInstance:nil forClass:[NSString class]];
    XCTAssertNil([self.diContainerToTest resolveForClass:[NSString class]], @"Registered instance by class was not removed");
}

- (void)testRegisteringInstanceForProtocol {
    
    // mock
    id instance = @"someInstance";
    id secondInstance = @"someSecondInstance";
    
    // run & assert - added
    [self.diContainerToTest registerInstance:instance forProtocol:@protocol(TestProtocol)];
    XCTAssertEqual([self.diContainerToTest resolveForProtocol:@protocol(TestProtocol)], instance, @"Registered instance by protocol was wrong resolved after adding");
    
    // run & assert - changed
    [self.diContainerToTest registerInstance:secondInstance forProtocol:@protocol(TestProtocol)];
    XCTAssertEqual([self.diContainerToTest resolveForProtocol:@protocol(TestProtocol)], secondInstance, @"Registered instance by protocol was wrong resolved after changing");
    
    // run & assert -- removed
    [self.diContainerToTest registerInstance:nil forProtocol:@protocol(TestProtocol)];
    XCTAssertNil([self.diContainerToTest resolveForProtocol:@protocol(TestProtocol)], @"Registered instance by protocol was not removed");
}

@end

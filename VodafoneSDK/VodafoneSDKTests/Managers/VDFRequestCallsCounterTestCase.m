//
//  VDFRequestCallsCounterTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFRequestCallsCounter.h"
#import "VDFBaseConfiguration.h"
#import "VDFBaseConfiguration+Manager.h"
#import "VDFDIContainer.h"

extern void __gcov_flush();

@interface VDFRequestCallsCounter ()
@property (nonatomic, strong) NSMutableDictionary *callsListPerClassType;
@end

@interface VDFRequestCallsCounterTestCase : XCTestCase
@property VDFRequestCallsCounter *counterToTest;
@property id mockDIContainer;
@end

@implementation VDFRequestCallsCounterTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockDIContainer = OCMClassMock([VDFDIContainer class]);
    self.counterToTest = [[VDFRequestCallsCounter alloc] initWithDIContainer:self.mockDIContainer];
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testIsIncrementingByCallTypeProperly {
    
    // mock
    NSDate *startDate = [NSDate date];
    Class classType = [NSObject class];
    
    // run
    [self.counterToTest incrementCallType:classType];
    [self.counterToTest incrementCallType:classType];
    
    // assert
    NSDate *endDate = [NSDate date];
    NSArray *callsDates = [self.counterToTest.callsListPerClassType valueForKey:NSStringFromClass([NSObject class])];
    NSDate *call1Date = [callsDates objectAtIndex:0];
    NSDate *call2Date = [callsDates objectAtIndex:1];
    XCTAssertTrue([startDate compare:call1Date] != NSOrderedDescending && [endDate compare:call1Date] != NSOrderedAscending, @"First call has wrong date");
    XCTAssertTrue([startDate compare:call2Date] != NSOrderedDescending && [endDate compare:call2Date] != NSOrderedAscending, @"Second call has wrong date");
}


- (void)testCanPerformRequest {
    
    // mock
    Class classType = [NSObject class];
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    configuration.requestsThrottlingLimit = 3;
    configuration.requestsThrottlingPeriod = 100;
    
    // stub
    [[[self.mockDIContainer stub] andReturn:configuration] resolveForClass:[VDFBaseConfiguration class]];
    
    // run
    BOOL resultWithoutIncrementation = [self.counterToTest canPerformRequestOfType:classType];
    [self.counterToTest incrementCallType:classType];
    [self.counterToTest incrementCallType:classType];
    BOOL resultWithIncrementationWhenNotExceededLimit = [self.counterToTest canPerformRequestOfType:classType];
    [self.counterToTest incrementCallType:classType];
    [self.counterToTest incrementCallType:classType];
    BOOL resultWithIncrementationWhenLimitExceeded = [self.counterToTest canPerformRequestOfType:classType];
    configuration.requestsThrottlingPeriod = -1;
    BOOL resultWithIncrementationWhenCallsExpired = [self.counterToTest canPerformRequestOfType:classType];
    
    // assert
    XCTAssertTrue(resultWithoutIncrementation, @"Result for type which was never incremented, should can be performed call.");
    XCTAssertTrue(resultWithIncrementationWhenNotExceededLimit, @"Result for type when limit is not exceeded is wrong.");
    XCTAssertFalse(resultWithIncrementationWhenLimitExceeded, @"Result for type when limit is exceeded is wrong.");
    XCTAssertTrue(resultWithIncrementationWhenCallsExpired, @"Result for type when all calls expired is wrong.");
}

@end

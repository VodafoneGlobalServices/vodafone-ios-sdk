//
//  VDFHttpConnectionsQueueTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 14/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFHttpConnectionsQueue.h"
#import "VDFServiceRequestsManager.h"
#import "VDFBaseConfiguration.h"
#import "VDFRequestBuilder.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersServiceDelegateMock.h"
#import "VDFHttpConnector.h"
#import "VDFCacheManager.h"
#import "VDFRequestFactory.h"
#import "VDFCacheObject.h"
#import "VDFPendingRequestItem.h"

extern void __gcov_flush();

@interface VDFHttpConnectionsQueue ()
// array of VDFPendingRequestItem objects
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (nonatomic, assign) VDFBaseConfiguration *configuration;
@property (nonatomic, strong) VDFCacheManager *cacheManager;

- (VDFPendingRequestItem*)findRequestItemByBuilder:(id<VDFRequestBuilder>)builder;
- (VDFPendingRequestItem*)createNewItemWithBuilder:(id<VDFRequestBuilder>)builder;

@end


@interface VDFHttpConnectionsQueueTestCase : XCTestCase

@property id queueToTestPartialMock;
@property id pendingRequestsMock;

@end

@implementation VDFHttpConnectionsQueueTestCase


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    VDFHttpConnectionsQueue *queueToTest = [[VDFHttpConnectionsQueue alloc] init];
    self.queueToTestPartialMock = OCMPartialMock(queueToTest);
    
    id pendingRequests = @[OCMClassMock([VDFPendingRequestItem class]), OCMClassMock([VDFPendingRequestItem class]),
                           OCMClassMock([VDFPendingRequestItem class]), OCMClassMock([VDFPendingRequestItem class]),
                           OCMClassMock([VDFPendingRequestItem class]), OCMClassMock([VDFPendingRequestItem class]),
                           OCMClassMock([VDFPendingRequestItem class]), OCMClassMock([VDFPendingRequestItem class])];
    self.pendingRequestsMock = OCMPartialMock([NSMutableArray arrayWithArray:pendingRequests]);
    
    queueToTest.pendingRequests = self.pendingRequestsMock;
    queueToTest.cacheManager = OCMClassMock([VDFCacheManager class]);
    queueToTest.configuration = OCMClassMock([VDFBaseConfiguration class]);
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEnqueueRequestBuilderWithNil {
    
    // mocks
    
    // expect that internal array do not be invoked
    [[self.pendingRequestsMock reject] addObject:[OCMArg any]];
    
    // run
    id result = [self.queueToTestPartialMock enqueueRequestBuilder:nil];
    
    // verify
    XCTAssertNil(result, @"Enqueue nil should return also nil.");
    [self.pendingRequestsMock verify];
    
}

- (void)testEnqueueRequestBuilderWithNotQueuedRequest {
    
    // mocks
    id mockedRequestBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    id mockedNewRequestItem = OCMClassMock([VDFPendingRequestItem class]);
    
    // expect that internal array will be invoked to add new item
    [[self.pendingRequestsMock expect] addObject:[OCMArg any]];
    
    // expect that queue will create new item for this builder
    [[[self.queueToTestPartialMock expect] andReturn:mockedNewRequestItem] createNewItemWithBuilder:mockedRequestBuilder];
    
    // expect that new request item will be started
    [[mockedNewRequestItem expect] startRequest];
    
    
    // run
    id result = [self.queueToTestPartialMock enqueueRequestBuilder:mockedRequestBuilder];
    
    // verify
    XCTAssertEqualObjects(result, mockedNewRequestItem, @"Enqueue should return mocked new request item");
    [self.queueToTestPartialMock verify];
    [self.pendingRequestsMock verify];
    [mockedNewRequestItem verify];
}

- (void)testEnqueueRequestBuilderWithQueuedRequest {
    
    // mocks
    id mockedNewRequestBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    id mockedNewObserversContainer = OCMProtocolMock(@protocol(VDFObserversContainer));
    
    id mockedPendingRequestItem = OCMClassMock([VDFPendingRequestItem class]);
    id mockedPendingRequestBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    id mockedPendingObserversContainer = OCMProtocolMock(@protocol(VDFObserversContainer));
    NSObject *mockedObserver = [[NSObject alloc] init];
    
    // expect that internal array will not be invoked
    [[self.pendingRequestsMock reject] addObject:[OCMArg any]];
    
    // expect that queue will find current pending item
    [[[self.queueToTestPartialMock expect] andReturn:mockedPendingRequestItem] findRequestItemByBuilder:mockedNewRequestBuilder];
    
    // expect that new request wont be started again
    [[mockedPendingRequestItem reject] startRequest];
    
    // expect that the builder observers will be readed from new builder
    [[[mockedNewRequestBuilder expect] andReturn:mockedNewObserversContainer] observersContainer];
    [[[mockedNewObserversContainer expect] andReturn:@[mockedObserver]] registeredObservers];
    
    // expect that the builder observers will be sent to the current pending builder
    [[[mockedPendingRequestItem expect] andReturn:mockedPendingRequestBuilder] builder];
    [[[mockedPendingRequestBuilder expect] andReturn:mockedPendingObserversContainer] observersContainer];
    [[mockedPendingObserversContainer expect] registerObserver:mockedObserver];
    
    
    // run
    id result = [self.queueToTestPartialMock enqueueRequestBuilder:mockedNewRequestBuilder];
    
    // verify
    XCTAssertEqualObjects(result, mockedPendingRequestItem, @"Enqueue should return mocked new request item");
    [self.queueToTestPartialMock verify];
    [self.pendingRequestsMock verify];
    [mockedNewRequestBuilder verify];
    [mockedNewObserversContainer verify];
    [mockedPendingRequestItem verify];
    [mockedPendingRequestBuilder verify];
    [mockedPendingObserversContainer verify];
}



- (void)testDequeueRequestItemWithNil {
    
    // expect that the internal array wont me invoked
    [[self.pendingRequestsMock reject] removeObject:[OCMArg any]];
    
    // run
    [self.queueToTestPartialMock dequeueRequestItem:nil];
    
    // verify
    [self.pendingRequestsMock verify];
    
}

- (void)testDequeueRequestWithQueuedItem {
    
    // mocks
    id mockedPendingRequestItem = OCMClassMock([VDFPendingRequestItem class]);
    
    // expect that the request item will be canceled
    [[mockedPendingRequestItem expect] cancelRequest];
    
    // expect that the internal array will be invoked for remove of item
    [[self.pendingRequestsMock expect] removeObject:mockedPendingRequestItem];
    
    
    // run
    [self.queueToTestPartialMock dequeueRequestItem:mockedPendingRequestItem];
    
    
    // verify
    [self.pendingRequestsMock verify];
    [mockedPendingRequestItem verify];
}


- (void)testAllPenidngRequestsAccess {
    
    // run
    NSArray *requests = [self.queueToTestPartialMock allPendingRequests];
    
    // verify:
    XCTAssertEqual([requests count], [self.pendingRequestsMock count], @"Number of returned items should equal.");
    for(int i=0; i<[self.pendingRequestsMock count]; i++) {
        XCTAssertEqualObjects([requests objectAtIndex:i], [self.pendingRequestsMock objectAtIndex:i], @"Items in returned array should be the same objects as in the mocked one.");
    }
}




- (void)testFindRequestItemByBuilderWithNil {
    
    // run:
    id result = [self.queueToTestPartialMock findRequestItemByBuilder:nil];
    
    // verify
    XCTAssertNil(result, @"Search for nil request item should return also nil result.");
    
}
- (void)testFindRequestItemByBuilderWithSuccess {
    
    // mock:
    id pendingRequestItemToFind = [self.pendingRequestsMock lastObject];
    id pendingRequestItemToFindBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    NSMutableArray *pendingRequestsItemsBuilders = [[NSMutableArray alloc] init];
    
    
    // expect on request item to find to be called getting builder
    [[[pendingRequestItemToFind expect] andReturn:pendingRequestItemToFindBuilder] builder];
    
    // expect to return YES on equality check on searching builder:
    [[[pendingRequestItemToFindBuilder expect] andReturnValue:@YES] isEqualToFactoryBuilder:pendingRequestItemToFindBuilder];
    
    // expect on every pending request would be fired getting builder and check equality of builder
    for (id requestItemMock in self.pendingRequestsMock) {
        if(requestItemMock != pendingRequestItemToFind) {
            id builder = OCMProtocolMock(@protocol(VDFRequestBuilder));
            
            // expect to be called on item get builder propety
            [[[requestItemMock expect] andReturn:builder] builder];
            
            // expect to be checked equality of builders
            [[[builder expect] andReturnValue:@NO] isEqualToFactoryBuilder:pendingRequestItemToFindBuilder];
            
            [pendingRequestsItemsBuilders addObject:builder];
        }
    }
    
    
    // run
    id result = [self.queueToTestPartialMock findRequestItemByBuilder:pendingRequestItemToFindBuilder];
    
    
    // verify:
    XCTAssertEqualObjects(result, pendingRequestItemToFind, @"Found Request item is incorrect.");
    [pendingRequestItemToFind verify];
    for (id mock in pendingRequestsItemsBuilders) { [mock verify]; }
    for (id mock in self.pendingRequestsMock) { [mock verify]; }
    
}

- (void)testFindRequestItemByBuilderWithNotFound {
    
    // mock:
    id pendingRequestItemToFind = [self.pendingRequestsMock lastObject];
    id pendingRequestItemToFindBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    NSMutableArray *pendingRequestsItemsBuilders = [[NSMutableArray alloc] init];
    
    
    // expect on request item to find to be called getting builder
    [[[pendingRequestItemToFind expect] andReturn:pendingRequestItemToFindBuilder] builder];
    
    // expect to return YES on equality check on searching builder:
    [[[pendingRequestItemToFindBuilder expect] andReturnValue:@YES] isEqualToFactoryBuilder:pendingRequestItemToFindBuilder];
    
    // expect on every pending request would be fired getting builder and check equality of builder
    for (id requestItemMock in self.pendingRequestsMock) {
        if(requestItemMock != pendingRequestItemToFind) {
            id builder = OCMProtocolMock(@protocol(VDFRequestBuilder));
            
            // expect to be called on item get builder propety
            [[[requestItemMock expect] andReturn:builder] builder];
            
            // expect to be checked equality of builders
            [[[builder expect] andReturnValue:@NO] isEqualToFactoryBuilder:pendingRequestItemToFindBuilder];
            
            [pendingRequestsItemsBuilders addObject:builder];
        }
    }
    
    
    // run
    id result = [self.queueToTestPartialMock findRequestItemByBuilder:pendingRequestItemToFindBuilder];
    
    
    // verify:
    XCTAssertEqualObjects(result, pendingRequestItemToFind, @"Found Request item is incorrect.");
    [pendingRequestItemToFind verify];
    for (id mock in pendingRequestsItemsBuilders) { [mock verify]; }
    for (id mock in self.pendingRequestsMock) { [mock verify]; }
}


- (void)testCreateNewItemWithBuilderWithNil {
    
    // run
    VDFPendingRequestItem *result = [self.queueToTestPartialMock createNewItemWithBuilder:nil];
    
    // verify:
    XCTAssertNil(result.builder, @"Creating new item from nil builder should return request item with nil builder.");
}

- (void)testCreateNewItemWithBuilderWithRealBuilder {
    
    // mock
    id mockedBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    
    // run
    VDFPendingRequestItem *result = [self.queueToTestPartialMock createNewItemWithBuilder:mockedBuilder];
    
    // verify:
    XCTAssertNotNil(result, @"Creating new item from existing builder object should return new item.");
    XCTAssertEqualObjects(result.builder, mockedBuilder, @"Builder of new request item and builder from parameter should be the same.");
}

@end

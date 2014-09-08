//
//  VDFServiceRequestsManagerTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFServiceRequestsManager.h"
#import "VDFBaseConfiguration.h"
#import "VDFRequestBuilder.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFHttpConnector.h"
#import "VDFCacheManager.h"
#import "VDFRequestFactory.h"
#import "VDFCacheObject.h"
#import "VDFHttpConnectionsQueue.h"
#import "VDFPendingRequestItem.h"
#import "VDFDIContainer.h"
#import "VDFRequestCallsCounter.h"
#import "VDFError.h"

extern void __gcov_flush();


@interface VDFServiceRequestsManager ()
@property (nonatomic, strong) VDFCacheManager *cacheManager;
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) VDFHttpConnectionsQueue *connectionsQueue;
@property (nonatomic, strong) VDFRequestCallsCounter *callsCounter;
@end


@interface VDFServiceRequestsManagerTestCase : XCTestCase
@property (nonatomic, strong) id mockBuilder;
@property (nonatomic, strong) id mockFactory;
@property (nonatomic, strong) id mockConnectionsQueue;
@property (nonatomic, strong) id mockCacheManager;
@property (nonatomic, strong) id mockCacheObject;
@property (nonatomic, strong) id mockObserversContainer;
@property (nonatomic, strong) id mockCallsCounter;
@property (nonatomic, strong) VDFServiceRequestsManager *managerToTest;
@end

@implementation VDFServiceRequestsManagerTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // mocks:
    self.mockBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    self.mockFactory = OCMProtocolMock(@protocol(VDFRequestFactory));
    self.mockConnectionsQueue = OCMClassMock([VDFHttpConnectionsQueue class]);
    self.mockCacheManager = OCMClassMock([VDFCacheManager class]);
    self.mockCacheObject = OCMClassMock([VDFCacheObject class]);
    self.mockObserversContainer = OCMProtocolMock(@protocol(VDFObserversContainer));
    self.mockCallsCounter = OCMClassMock([VDFRequestCallsCounter class]);
    
    // test object
    self.managerToTest = [[VDFServiceRequestsManager alloc] initWithDIContainer:nil cacheManager:self.mockCacheManager];
    self.managerToTest.connectionsQueue = self.mockConnectionsQueue;
    self.managerToTest.callsCounter = self.mockCallsCounter;
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInit {
    
    // mock
    id mockDIContainer = OCMClassMock([VDFDIContainer class]);
    
    self.managerToTest = [[VDFServiceRequestsManager alloc] initWithDIContainer:mockDIContainer cacheManager:self.mockCacheManager];
    
    XCTAssertEqualObjects(mockDIContainer, self.managerToTest.diContainer, @"DIContainer passed through init method is not assigned properly.");
    XCTAssertEqualObjects(self.mockCacheManager, self.managerToTest.cacheManager, @"Cache manager passed through init method is not assigned properly.");
    XCTAssertNotNil(self.managerToTest.connectionsQueue, @"Connections queue should be initialized in init method.");
}

- (void)testPerformRequestWithDependentRequest
{
    // mocks:
    id dependentBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    id mockManagerToTest = OCMPartialMock(self.managerToTest);
    
    // expect:
    [[[self.mockBuilder expect] andReturn:dependentBuilder] dependentRequestBuilder];
    [[self.mockBuilder expect] setResumeTarget:self.managerToTest selector:@selector(performRequestWithBuilder:)];
    [[mockManagerToTest expect] performRequestWithBuilder:dependentBuilder];
    
    // run:
    [mockManagerToTest performRequestWithBuilder:self.mockBuilder];
    
    // verify
    [self.mockBuilder verify];
    [mockManagerToTest verify];
}

- (void)testPerformRequestIsAddingToQueueAndNotCacheble {
    
    // stub:
    [[[self.mockCallsCounter stub] andReturnValue:@YES] canPerformRequestOfType:[self.mockBuilder class]];
    
    // expect that the call counter will be incremented
    [[self.mockCallsCounter expect] incrementCallType:[self.mockBuilder class]];
    
    // expect that the request would be added to queue:
    [[self.mockConnectionsQueue expect] enqueueRequestBuilder:self.mockBuilder];
    
    // expect that the factory from builder would be obtained
    [[[self.mockBuilder expect] andReturn:self.mockFactory] factory];
    
    // expect that the cache object would be obtained from factory
    [[[self.mockFactory expect] andReturn:nil] createCacheObject];
    
    // run:
    [self.managerToTest performRequestWithBuilder:self.mockBuilder];
    
    // verify
    [self.mockFactory verify];
    [self.mockBuilder verify];
    [self.mockConnectionsQueue verify];
    [self.mockCallsCounter verify];
}

- (void)testPerformeRequestWhenResponseIsReadedFromCache {
    
    id cachedValue = [[NSObject alloc] init];
    
    // stubbing that check in isObjectCache method can be invoked on manager and it would resturn YES:
    [[[self.mockCacheManager stub] andReturnValue:@YES] isObjectCached:self.mockCacheObject];
    
    
    // expect that the call counter wont be incremented
    [[self.mockCallsCounter reject] incrementCallType:[self.mockBuilder class]];
    
    // expect that the request would not be added to queue:
    [[self.mockConnectionsQueue reject] enqueueRequestBuilder:self.mockBuilder];
    
    // expect that the factory from builder would be obtained
    [[[self.mockBuilder expect] andReturn:self.mockFactory] factory];
    
    // expect that the cache object would be obtained from factory
    [[[self.mockFactory expect] andReturn:self.mockCacheObject] createCacheObject];
    
    // expec that readed object from cache manager would return cached value
    [[[self.mockCacheManager expect] andReturn:cachedValue] readCacheObject:self.mockCacheObject];
    
    // expect that the observers container would be obtained from builder
    [[[self.mockBuilder expect] andReturn:self.mockObserversContainer] observersContainer];
    
    // expect that the all observers would be notified with readed cache value
    [[self.mockObserversContainer expect] notifyAllObserversWith:cachedValue error:nil];
    
    // run:
    [self.managerToTest performRequestWithBuilder:self.mockBuilder];
    
    // verify
    [self.mockCacheManager verify];
    [self.mockConnectionsQueue verify];
    [self.mockFactory verify];
    [self.mockBuilder verify];
    [self.mockObserversContainer verify];
    [self.mockCallsCounter verify];
}

- (void)testPerformRequestWhenResponseIsCachableButNotAvailableInCache {
    
    id cachedValue = [[NSObject alloc] init];
    
    // stub that check in isObjectCache method can be invoked on manager and it would resturn YES:
    [[[self.mockCacheManager stub] andReturnValue:@NO] isObjectCached:self.mockCacheObject];
    
    // stub that readed object from cache manager would not return value
    [[[self.mockCacheManager stub] andReturn:cachedValue] readCacheObject:self.mockCacheObject];
    
    // stub that the observers container can be obtained from builder
    [[[self.mockBuilder stub] andReturn:self.mockObserversContainer] observersContainer];
    
    // stub calls counter call
    [[[self.mockCallsCounter stub] andReturnValue:@YES] canPerformRequestOfType:[self.mockBuilder class]];
    
    
    // expect that the call counter will be incremented
    [[self.mockCallsCounter expect] incrementCallType:[self.mockBuilder class]];
    
    // expect that the request would be added to queue:
    [[self.mockConnectionsQueue expect] enqueueRequestBuilder:self.mockBuilder];
    
    // expect that the factory from builder would be obtained
    [[[self.mockBuilder expect] andReturn:self.mockFactory] factory];
    
    // expect that the cache object would be obtained from factory
    [[[self.mockFactory expect] andReturn:self.mockCacheObject] createCacheObject];
    
    // expect that the observers would not be notified
    [[self.mockObserversContainer reject] notifyAllObserversWith:[OCMArg any] error:[OCMArg any]];
    
    // run:
    [self.managerToTest performRequestWithBuilder:self.mockBuilder];
    
    // verify
    [self.mockCacheManager verify];
    [self.mockConnectionsQueue verify];
    [self.mockFactory verify];
    [self.mockBuilder verify];
    [self.mockObserversContainer verify];
    [self.mockCallsCounter verify];
}

- (void)testPerformRequestWithNilBuilder {
    
    // expect that nil wont be added to the queue:
    [[self.mockConnectionsQueue reject] enqueueRequestBuilder:[OCMArg any]];
    
    // expect that cache manager wont be invoked
    [[self.mockCacheManager reject] isObjectCached:[OCMArg any]];
    [[self.mockCacheManager reject] readCacheObject:[OCMArg any]];
    
    // run:
    XCTAssertNoThrow([self.managerToTest performRequestWithBuilder:nil], @"Performing request with nil builder should do nothing.");
    
    // verify
    [self.mockConnectionsQueue verify];
    [self.mockCacheManager verify];
}

- (void)testPerformRequestWhenCallIsThrottled {
    
    // stub:
    [[[self.mockCallsCounter stub] andReturnValue:@NO] canPerformRequestOfType:[self.mockBuilder class]];
    
    
    // expect that the call counter wont be incremented
    [[self.mockCallsCounter reject] incrementCallType:[self.mockBuilder class]];
    
    // expect that the request wont be added to queue:
    [[self.mockConnectionsQueue reject] enqueueRequestBuilder:self.mockBuilder];
    
    // expect that the observers container would be obtained from builder
    [[[self.mockBuilder expect] andReturn:self.mockObserversContainer] observersContainer];
    
    // expect that the all observers would be notified with error
    [[self.mockObserversContainer expect] notifyAllObserversWith:nil error:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [((NSError*)obj).domain isEqualToString:VodafoneErrorDomain] && ((NSError*)obj).code == VDFErrorThrottlingLimitExceeded;
    }]];
    
    // run:
    [self.managerToTest performRequestWithBuilder:self.mockBuilder];
    
    // verify
    [self.mockBuilder verify];
    [self.mockConnectionsQueue verify];
    [self.mockObserversContainer verify];
    [self.mockCallsCounter verify];
}

- (void)testRemoveRequestWithNilObserver {
    
    // expect that the connections queue will not be called for list of all requests
    [[self.mockConnectionsQueue reject] allPendingRequests];
    
    // expect that any of the requests wont be removed
    [[self.mockConnectionsQueue reject] dequeueRequestItem:[OCMArg any]];
    
    // run:
    XCTAssertNoThrow([self.managerToTest removeRequestObserver:nil], @"Remove of nil observer should do nothing.");
    
    // verify
    [self.mockConnectionsQueue verify];
}

- (void)testRemoveRequestObserverWithoutEndingTasks {
    // ending taksks means that removed observer was last and the request need to be dequeued
    
    id observerToRemove = [[NSObject alloc] init];
    NSMutableArray *pendingRequestBuilders = [[NSMutableArray alloc] init];
    NSMutableArray *pendingRequestObserversContainers = [[NSMutableArray alloc] init];
    NSMutableArray *pendingRequests = [[NSMutableArray alloc] init];
    
    // setting expectations to all pending requests:
    for (int i=0; i<10; i++) {
        
        id mockItemBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
        id mockItemObserversContainer = OCMProtocolMock(@protocol(VDFObserversContainer));
        
        // expect also that every observers container of request item will be invoked with the observer to remove
        [[mockItemObserversContainer expect] unregisterObserver:observerToRemove];
        
        // expect that the every builder will have own observersContainer:
        [[[mockItemBuilder expect] andReturn:mockItemObserversContainer] observersContainer];
        
        // expect that the every observers container will still have any observers registered
        [[[mockItemObserversContainer expect] andReturnValue:OCMOCK_VALUE((NSUInteger)1)] count];
        
        // setting builder for request
        VDFPendingRequestItem *requestItem = [[VDFPendingRequestItem alloc] init];
        requestItem.builder = mockItemBuilder;
        
        [pendingRequests addObject:requestItem];
        [pendingRequestObserversContainers addObject:mockItemObserversContainer];
        [pendingRequestBuilders addObject:mockItemBuilder];
    }
    
    // expect that the connections queue will be called and returned list of all requests
    [[[self.mockConnectionsQueue expect] andReturn:pendingRequests] allPendingRequests];
    
    // expect that any of the requests wont be removed
    [[self.mockConnectionsQueue reject] dequeueRequestItem:[OCMArg any]];
    
    // run:
    [self.managerToTest removeRequestObserver:observerToRemove];
    
    // verify
    for (id mockObject in pendingRequestBuilders) { [mockObject verify]; }
    for (id mockObject in pendingRequestObserversContainers) { [mockObject verify]; }
    [self.mockConnectionsQueue verify];
}

- (void)testRemoveRequestObserverWithEndingTasks {
    // ending taksks means that removed observer was last and the request need to be dequeued
    
    id observerToRemove = [[NSObject alloc] init];
    NSMutableArray *pendingRequestBuilders = [[NSMutableArray alloc] init];
    NSMutableArray *pendingRequestObserversContainers = [[NSMutableArray alloc] init];
    NSMutableArray *pendingRequests = [[NSMutableArray alloc] init];
    
    // setting expectations to all pending requests:
    for (int i=0; i<10; i++) {
        
        id mockItemBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
        id mockItemObserversContainer = OCMProtocolMock(@protocol(VDFObserversContainer));
        
        // expect also that every observers container of request item will be invoked with the observer to remove
        [[mockItemObserversContainer expect] unregisterObserver:observerToRemove];
        
        // expect that the every builder will have own observersContainer:
        [[[mockItemBuilder expect] andReturn:mockItemObserversContainer] observersContainer];
        
        // expect that the every observers container will still have any observers registered
        [[[mockItemObserversContainer expect] andReturnValue:OCMOCK_VALUE((NSUInteger)(i%2))] count];
        
        // setting builder for request
        VDFPendingRequestItem *requestItem = [[VDFPendingRequestItem alloc] init];
        requestItem.builder = mockItemBuilder;
        
        if((i%2) == 0) {
            // expect that this requests will be removed from queue because has not any observers
            [[self.mockConnectionsQueue expect] dequeueRequestItem:requestItem];
        } else {
            // expect that this request wont be removed
            [[self.mockConnectionsQueue reject] dequeueRequestItem:requestItem];
        }
        
        [pendingRequests addObject:requestItem];
        [pendingRequestObserversContainers addObject:mockItemObserversContainer];
        [pendingRequestBuilders addObject:mockItemBuilder];
    }
    
    // expect that the connections queue will be called and returned list of all requests
    [[[self.mockConnectionsQueue expect] andReturn:pendingRequests] allPendingRequests];
    
    // run:
    [self.managerToTest removeRequestObserver:observerToRemove];
    
    // verify
    for (id mockObject in pendingRequestBuilders) { [mockObject verify]; }
    for (id mockObject in pendingRequestObserversContainers) { [mockObject verify]; }
    [self.mockConnectionsQueue verify];
}

@end

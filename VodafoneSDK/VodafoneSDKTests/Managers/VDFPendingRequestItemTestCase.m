//
//  VDFPendingRequestItemTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 18/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFPendingRequestItem.h"
#import "VDFHttpConnectionsQueue.h"
#import "VDFCacheManager.h"
#import "VDFHttpConnector.h"
#import "VDFBaseConfiguration.h"
#import "VDFError.h"
#import "VDFCacheObject.h"
#import "VDFHttpConnectorResponse.h"

extern void __gcov_flush();


@interface VDFPendingRequestItem ()
@property (nonatomic, strong) VDFHttpConnectionsQueue *parentQueue;
@property (nonatomic, strong) VDFCacheManager *cacheManager;
// pending http request to the server
@property (nonatomic, strong) VDFHttpConnector *currentHttpRequest;
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
@property (nonatomic, assign) BOOL isRunning;

- (void)retryRequest;
- (void)startHttpRequest;
- (void)onInternalConnectionError:(VDFErrorCode)errorCode;
- (void)safeDequeueRequest;
- (void)parseAndNotifyWithResponse:(VDFHttpConnectorResponse*)response;
@end



@interface VDFPendingRequestItemTestCase : XCTestCase

@property id itemToTestPartialMock;
@property id mockBuilder;
@property id mockParentQueue;
@property id mockCacheManager;
@property id mockHttpRequest;
@property id mockConfiguration;
@property VDFPendingRequestItem *itemToTest;
@property id mockRequestState;
@property id mockResponseParser;
@property id mockFactory;
@property id mockObserversContainer;

@end

@implementation VDFPendingRequestItemTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
    self.mockParentQueue = OCMClassMock([VDFHttpConnectionsQueue class]);
    self.mockCacheManager = OCMClassMock([VDFCacheManager class]);
    self.mockConfiguration = OCMClassMock([VDFBaseConfiguration class]);
    
    // mocking builder:
    self.mockRequestState = OCMProtocolMock(@protocol(VDFRequestState));
    self.mockResponseParser = OCMProtocolMock(@protocol(VDFResponseParser));
    self.mockFactory = OCMProtocolMock(@protocol(VDFRequestFactory));
    self.mockObserversContainer = OCMProtocolMock(@protocol(VDFObserversContainer));
    self.mockHttpRequest = OCMClassMock([VDFHttpConnector class]);
    
    
    self.itemToTest = [[VDFPendingRequestItem alloc] initWithBuilder:self.mockBuilder parentQueue:self.mockParentQueue
                                                                          cacheManager:self.mockCacheManager configuration:self.mockConfiguration];
    self.itemToTest.currentHttpRequest = self.mockHttpRequest;
    self.itemToTestPartialMock = OCMPartialMock(self.itemToTest);
    
    [[[self.mockBuilder stub] andReturn:self.mockRequestState] requestState];
    [[[self.mockBuilder stub] andReturn:self.mockResponseParser] responseParser];
    [[[self.mockBuilder stub] andReturn:self.mockFactory] factory];
    [[[self.mockBuilder stub] andReturn:self.mockObserversContainer] observersContainer];
    [[[self.mockBuilder stub] andReturn:self.mockHttpRequest] createCurrentHttpConnectorWithDelegate:[OCMArg any]];
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


/*
 - (instancetype)initWithBuilder:(id<VDFRequestBuilder>)builder parentQueue:(VDFHttpConnectionsQueue*)parentQueue cacheManager:(VDFCacheManager*)cacheManager configuration:(VDFBaseConfiguration*)configuration;
 
 // TODO documentation
 @property (nonatomic, strong) id<VDFRequestBuilder> builder;
 // number of all http requests made for this holder
 @property (nonatomic, assign) NSInteger numberOfRetries;
 
 - (void)startRequest;
 
 - (void)cancelRequest;
 
 */


- (void)testStartRequestWhenNotRunning {
    
    // mock:
    self.itemToTest.isRunning = NO;
    
    // expect that the Http request will be started
    [[self.itemToTestPartialMock expect] startHttpRequest];
    
    // run
    [self.itemToTestPartialMock startRequest];
    
    // verify
    XCTAssertTrue(self.itemToTest.isRunning, @"After starting request flag isRunning should be set to YES");
    [self.itemToTestPartialMock verify];
}

- (void)testStartRequestWhenRunning {
    
    // mock:
    self.itemToTest.isRunning = YES;
    
    // expect that the http request cannot be started
    [[self.itemToTestPartialMock reject] startHttpRequest];
    
    // run
    [self.itemToTestPartialMock startRequest];
    
    // verify
    XCTAssertTrue(self.itemToTest.isRunning, @"After starting request flag isRunning should not change");
    [self.itemToTestPartialMock verify];
}





- (void)testCancelRequestWhenNotRunning {
    
    // mock:
    self.itemToTest.isRunning = NO;
    
    // expect that the http request wont be stopped
    [[self.mockHttpRequest reject] cancelCommunication];
    
    // run
    [self.itemToTestPartialMock cancelRequest];
    
    // verify
    XCTAssertFalse(self.itemToTest.isRunning, @"After canceling not running request, isRunning flag should be still set to NO.");
    [self.mockHttpRequest verify];
}

- (void)testCancelRequestWhenRunning {
    
    // mock:
    self.itemToTest.isRunning = YES;
    
    // expect that the http request will be stopped
    [[self.mockHttpRequest expect] cancelCommunication];
    
    // expect that the http communication state will be readed
    [[[self.mockHttpRequest expect] andReturnValue:@YES] isRunning];
    
    // run
    [self.itemToTestPartialMock cancelRequest];
    
    // verify
    XCTAssertFalse(self.itemToTest.isRunning, @"After canceling running request, isRunning flag should be set to NO.");
    [self.mockHttpRequest verify];
}

- (void)testCancelRequestWhenRunningAndHttpRequestEnded {
    
    // mock:
    self.itemToTest.isRunning = YES;
    
    // expect that the http request wont be canceled
    [[self.mockHttpRequest reject] cancelCommunication];
    
    // expect that the state of http request will be readed
    [[[self.mockHttpRequest expect] andReturnValue:@NO] isRunning];
    
    // run
    [self.itemToTestPartialMock cancelRequest];
    
    // verify
    XCTAssertFalse(self.itemToTest.isRunning, @"After canceling running request, isRunning flag should be set to NO.");
    [self.mockHttpRequest verify];
}



- (void)testStartHttpRequestWithoutError {
    
    // expect that the http request will be started
    [[[self.mockHttpRequest expect] andReturnValue:@0] startCommunication];
    
    // expect that the stop request wont be fired
    [[[self.itemToTestPartialMock reject] ignoringNonObjectArgs] onInternalConnectionError:0];
    
    // run
    [self.itemToTestPartialMock startHttpRequest];
    
    // verify
    [self.mockHttpRequest verify];
    [self.itemToTestPartialMock verify];
}

- (void)testStartHttpRequestWithError {
    
    // expect that the http request will be started
    [[[self.mockHttpRequest expect] andReturnValue:@3] startCommunication];
    
    // expect that the request will be stopped with error code
    [[self.itemToTestPartialMock expect] onInternalConnectionError:VDFErrorNoConnection];
    
    // run
    [self.itemToTestPartialMock startHttpRequest];
    
    // verify
    [self.mockHttpRequest verify];
    [self.itemToTestPartialMock verify];
}


- (void)testOnInternalConnectionErrorIsDequeueAndObserversNotifyProperly {
    
    // mock
    id mockObserversContainer = OCMProtocolMock(@protocol(VDFObserversContainer));
    
    // expect that the item will dequeue self from queue
    [[self.itemToTestPartialMock expect] safeDequeueRequest];
    
    // expect that the observers will be notified
    [[[self.mockBuilder expect] andReturn:mockObserversContainer] observersContainer];
    [[mockObserversContainer expect] notifyAllObserversWith:nil error:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [((NSError*)obj) code] == VDFErrorNoConnection;
    }]];
    
    // run
    [self.itemToTestPartialMock onInternalConnectionError:VDFErrorNoConnection];
    
    // verify
    XCTAssertFalse(self.itemToTest.isRunning, @"After stop request with error code the isRunning flag should be set to NO.");
    [self.itemToTestPartialMock verify];
}




- (void)testRetryRequestWhenNumberOfRetriesExceeds {
    
    // mock
    self.itemToTest.numberOfRetries = 2;
    
    // stub
    [[[self.mockConfiguration stub] andReturnValue:@1] maxHttpRequestRetriesCount];
    [[[self.mockConfiguration stub] andReturnValue:@1] httpRequestRetryTimeSpan];
    
    // expect that the on error method will be fired
    [[self.itemToTestPartialMock expect] onInternalConnectionError:VDFErrorConnectionTimeout];
    
    // expect that the http request wont be started again
    [[self.itemToTestPartialMock reject] startHttpRequest];
    
    // run
    [self.itemToTestPartialMock retryRequest];
    
    // verify
    XCTAssertEqual(self.itemToTest.numberOfRetries, 3, @"After retrying request number of retries should +=1");
    [self.itemToTestPartialMock verifyWithDelay:2];
}

- (void)testRetryRequestWhenObserversNotAvailable {
    
    // mock
    self.itemToTest.isRunning = YES;
    self.itemToTest.numberOfRetries = 0;
    
    
    // stub
    [[[self.mockConfiguration stub] andReturnValue:@5] maxHttpRequestRetriesCount];
    
    
    // expect that the request retry time span will be readed
    [[[self.mockConfiguration expect] andReturnValue:@1.0] httpRequestRetryTimeSpan];
    
    // expect that the on error method will not be fired
    [[[self.itemToTestPartialMock reject] ignoringNonObjectArgs] onInternalConnectionError:0];
    
    // expect that the http request wont be started again
    [[self.itemToTestPartialMock reject] startHttpRequest];
    
    // expect that the observers count will be readed:
    [[[self.mockObserversContainer expect] andReturnValue:OCMOCK_VALUE((NSUInteger)0)] count];
    
    // expect that the request will end running end dequeue
    [[self.itemToTestPartialMock expect] safeDequeueRequest];
    
    
    // run
    [self.itemToTestPartialMock retryRequest];
    
    
    // verify
    [self.itemToTestPartialMock verifyWithDelay:2];
    XCTAssertEqual(self.itemToTest.numberOfRetries, 1, @"After retrying request number of retries should +=1");
    XCTAssertFalse(self.itemToTest.isRunning, @"After retrying request and no observers are waiting the isRunning flag should be set to NO.");
    [self.mockObserversContainer verify];
    [self.mockConfiguration verify];
}

- (void)testRetryRequestWhenObserversAvailable {
    
    // mock
    self.itemToTest.isRunning = YES;
    self.itemToTest.numberOfRetries = 0;
    
    
    // stub
    [[[self.mockConfiguration stub] andReturnValue:@5] maxHttpRequestRetriesCount];
    
    
    // expect that the request retry time span will be readed
    [[[self.mockConfiguration expect] andReturnValue:@1.0] httpRequestRetryTimeSpan];
    
    // expect that the on error method will not be fired
    [[[self.itemToTestPartialMock reject] ignoringNonObjectArgs] onInternalConnectionError:0];
    
    // expect that the http request will be started again
    [[self.itemToTestPartialMock expect] startHttpRequest];
    
    // expect that the observers count will be readed:
    [[[self.mockObserversContainer expect] andReturnValue:OCMOCK_VALUE((NSUInteger)1)] count];
    
    // expect that the request wont dequeue
    [[self.itemToTestPartialMock reject] safeDequeueRequest];
    
    
    // run
    [self.itemToTestPartialMock retryRequest];
    
    
    // verify
    XCTAssertEqual(self.itemToTest.numberOfRetries, 1, @"After retrying request number of retries should +=1");
    XCTAssertTrue(self.itemToTest.isRunning, @"After retrying request and no observers are waiting the isRunning flag should not change.");
    [self.itemToTestPartialMock verifyWithDelay:2];
    [self.mockObserversContainer verify];
    [self.mockConfiguration verify];
}


- (void)testSafeDequeue {
    
    // expect that the dequeue method will be fired
    [[self.mockParentQueue expect] dequeueRequestItem:self.itemToTest];
    
    // run
    [self.itemToTestPartialMock safeDequeueRequest];
    
    // verify
    [self.mockParentQueue verify];
}


- (void)testOnHttpResponseWithRetryNeeded {
    
    // mock
    id mockedData = [[NSData alloc] init];
    NSInteger mockedResponseCode = 200;
    id mockedError = [[NSObject alloc] init];
    id mockHttpConnector = OCMClassMock([VDFHttpConnector class]);
    id mockHttpResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stubs
    [[[self.mockRequestState stub] andReturnValue:@YES] isRetryNeeded];
    [[[mockHttpConnector stub] andReturnValue:OCMOCK_VALUE(mockedResponseCode)] lastResponseCode];
    [[[mockHttpResponse stub] andReturn:mockedData] data];
    [[[mockHttpResponse stub] andReturnValue:OCMOCK_VALUE(mockedResponseCode)] httpResponseCode];
    [[[mockHttpResponse stub] andReturn:mockedError] error];
    
    // expect that the parse method will be invoked:
    [[self.itemToTestPartialMock expect] parseAndNotifyWithResponse:mockHttpResponse];
    
    // expect that the retry method will be invoked
    [[self.itemToTestPartialMock expect] retryRequest];
    
    // expect that this request wont be closed
    [[self.itemToTestPartialMock reject] safeDequeueRequest];
    
    
    // run
    [self.itemToTestPartialMock httpRequest:mockHttpConnector onResponse:mockHttpResponse];
    
    
    // verify
    [self.itemToTestPartialMock verify];
}

- (void)testOnHttpResponseWithRetryNotNeeded {
    
    // mock
    id mockedData = [[NSData alloc] init];
    NSInteger mockedResponseCode = 200;
    id mockedError = [[NSObject alloc] init];
    id mockHttpConnector = OCMClassMock([VDFHttpConnector class]);
    id mockHttpResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stubs
    [[[self.mockRequestState stub] andReturnValue:@NO] isRetryNeeded];
    [[[mockHttpConnector stub] andReturnValue:OCMOCK_VALUE(mockedResponseCode)] lastResponseCode];
    [[[mockHttpResponse stub] andReturn:mockedData] data];
    [[[mockHttpResponse stub] andReturnValue:OCMOCK_VALUE(mockedResponseCode)] httpResponseCode];
    [[[mockHttpResponse stub] andReturn:mockedError] error];
    
    // expect that the parse method will be invoked:
    [[self.itemToTestPartialMock expect] parseAndNotifyWithResponse:mockHttpResponse];
    
    // expect that the retry method wont be invoked
    [[self.itemToTestPartialMock reject] retryRequest];
    
    // expect that this request will be closed
    [[self.itemToTestPartialMock expect] safeDequeueRequest];
    
    
    // run
    [self.itemToTestPartialMock httpRequest:mockHttpConnector onResponse:mockHttpResponse];
    
    
    // verify
    [self.itemToTestPartialMock verify];
}



- (void)testParseAndNotifyWithError {
    
    // mock
    id mockedData = [[NSData alloc] init];
    NSInteger mockedResponseCode = 200;
    id mockedError = [[NSObject alloc] init];
    id mockHttpResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stubs
    [[[mockHttpResponse stub] andReturn:mockedData] data];
    [[[mockHttpResponse stub] andReturnValue:OCMOCK_VALUE(mockedResponseCode)] httpResponseCode];
    [[[mockHttpResponse stub] andReturn:mockedError] error];
    
    // expect to update request state with response code:
    [[self.mockRequestState expect] updateWithHttpResponse:mockHttpResponse];
    
    // expect that the parser will be invoked to parse whole response
    [[self.mockResponseParser expect] parseResponse:mockHttpResponse];
    
    // expect that the request state object will be updated after parsing even if it will be nil object
    [[self.mockRequestState expect] updateWithParsedResponse:[OCMArg any]];
    
    // expect that the factory wont be invoked to create cache object:
    [[self.mockFactory reject] createCacheObject];
    
    // expect that the cache manager wont be invoked to store object in cache
    [[self.mockCacheManager reject] cacheObject:[OCMArg any]];
    
    // expect that the observers will be notified
    [[self.mockObserversContainer expect] notifyAllObserversWith:[OCMArg isNil] error:mockedError];
    
    // run
    [self.itemToTestPartialMock parseAndNotifyWithResponse:mockHttpResponse];
    
    
    // verify
    [self.mockRequestState verify];
    [self.mockResponseParser verify];
    [self.mockFactory verify];
    [self.mockCacheManager verify];
    [self.mockObserversContainer verify];
}

- (void)testParseAndNotifyWithNoErrorWithCaching {
    
    // mock
    id mockedData = [[NSData alloc] init];
    NSInteger mockedResponseCode = 200;
    id mockedParsedObject = [[NSObject alloc] init];
    id mockCacheObject = OCMClassMock([VDFCacheObject class]);
    id mockHttpResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stubs
    [[[mockHttpResponse stub] andReturn:mockedData] data];
    [[[mockHttpResponse stub] andReturnValue:OCMOCK_VALUE(mockedResponseCode)] httpResponseCode];
    
    // expect to update request state with response code:
    [[self.mockRequestState expect] updateWithHttpResponse:mockHttpResponse];
    
    // expect that the parser will parse data
    [[[self.mockResponseParser expect] andReturn:mockedParsedObject] parseResponse:mockHttpResponse];
    
    // expect that the request state object will be updated after parsing
    [[self.mockRequestState expect] updateWithParsedResponse:mockedParsedObject];
    
    // expect that the factory will be invoked to create cache object:
    [[[self.mockFactory expect] andReturn:mockCacheObject] createCacheObject];
    
    // expect that on the cache object will be set parsed value:
    [[mockCacheObject expect] setCacheValue:mockedParsedObject];
    
    // expect that the cache manager will be invoked to store object in cache
    [[self.mockCacheManager expect] cacheObject:mockCacheObject];
    
    // expect that the observers will be notified
    [[self.mockObserversContainer expect] notifyAllObserversWith:mockedParsedObject error:[OCMArg isNil]];
    
    // run
    [self.itemToTestPartialMock parseAndNotifyWithResponse:mockHttpResponse];
    
    
    // verify
    [self.mockRequestState verify];
    [self.mockResponseParser verify];
    [self.mockFactory verify];
    [self.mockCacheManager verify];
    [self.mockObserversContainer verify];
    [mockCacheObject verify];
}

- (void)testParseAndNotifyWithNoErrorWithNotCaching {
    
    // mock
    id mockedData = [[NSData alloc] init];
    NSInteger mockedResponseCode = 200;
    id mockedParsedObject = [[NSObject alloc] init];
    id mockHttpResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stubs
    [[[mockHttpResponse stub] andReturn:mockedData] data];
    [[[mockHttpResponse stub] andReturnValue:OCMOCK_VALUE(mockedResponseCode)] httpResponseCode];
    
    // expect that the parser will parse data
    [[[self.mockResponseParser expect] andReturn:mockedParsedObject] parseResponse:mockHttpResponse];
    
    // expect that the request state object will be updated after parsing
    [[self.mockRequestState expect] updateWithParsedResponse:mockedParsedObject];
    
    // expect that the factory will be invoked to create cache object but cache object is nil because it is not caching:
    [[[self.mockFactory expect] andReturn:nil] createCacheObject];
    
    // expect that the cache manager wont be invoked to store any object in cache
    [[self.mockCacheManager reject] cacheObject:[OCMArg any]];
    
    // expect that the observers will be notified
    [[self.mockObserversContainer expect] notifyAllObserversWith:mockedParsedObject error:[OCMArg isNil]];
    
    // run
    [self.itemToTestPartialMock parseAndNotifyWithResponse:mockHttpResponse];
    
    
    // verify
    [self.mockRequestState verify];
    [self.mockResponseParser verify];
    [self.mockFactory verify];
    [self.mockCacheManager verify];
    [self.mockObserversContainer verify];
}



@end

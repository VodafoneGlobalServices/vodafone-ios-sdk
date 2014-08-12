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
#import "VDFUsersServiceDelegateMock.h"
#import "VDFHttpConnector.h"
#import "VDFCacheManager.h"
#import "VDFRequestFactory.h"
#import "VDFCacheObject.h"
#import "VDFHttpConnectionsQueue.h"

extern void __gcov_flush();


@interface VDFServiceRequestsManager ()
@property (nonatomic, strong) VDFCacheManager *cacheManager;
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
@property (nonatomic, strong) VDFHttpConnectionsQueue *connectionsQueue;
@property (nonatomic, strong) NSObject *synchronizationUnit;
@end


@interface VDFServiceRequestsManagerTestCase : XCTestCase
@property VDFBaseConfiguration *config;
@property id mockCacheManager;

@property id mockConfig;
@end

@implementation VDFServiceRequestsManagerTestCase

/*
 - (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration cacheManager:(VDFCacheManager*)cacheManager;

 // checks cache
 // if cache objects exists sends it to the observers
 // if not add this to queue
- (void)performRequestWithBuilder:(id<VDFRequestBuilder>)request;

- (void)removeRequestObserver:(id)requestDelegate;
 
*/


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.config = [[VDFBaseConfiguration alloc] init];
    self.config.applicationId = @"some test app id";
    self.config.sdkVersion = @"1.0000.01";
    self.config.backEndBaseUrl = @"http://some.fake.url.com";
//    self.config.cacheDirectoryPath = @"cache_dir";
    self.config.defaultHttpConnectionTimeout = 60;
    self.config.httpRequestRetryTimeSpan = 1000;
    self.config.maxHttpRequestRetriesCount = 60;
    
//    self.cacheManagerMock =
    
    
    
    
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testNotCachedObjectIaAddedToQueue {
//    
//    // mocking class:
//    id mockCacheManager = OCMClassMock([VDFCacheManager class]);
//    id mockConfig = OCMClassMock([VDFBaseConfiguration class]);
////    id mockConnectionsQueue = OCMClassMock([VDF]);
//    
//    id mockBuilder = OCMProtocolMock(@protocol(VDFRequestBuilder));
//    
//    // stubbing mocks:
//    [[[mockCacheManager stub] andReturnValue:@NO] isObjectCached:[OCMArg any]];
//    
//    VDFServiceRequestsManager *managerToTest = [[VDFServiceRequestsManager alloc] initWithConfiguration:mockConfig
//                                                                                           cacheManager:mockCacheManager];
//    
//    managerToTest performRequestWithBuilder:
//}

- (void)testPerformingCachedResponse {
    // test requests on manager where response is cached
}

- (void)testPerformOfRequest {
}

- (void)testRetryRequests {
}


@end

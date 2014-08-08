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

extern void __gcov_flush();

@interface VDFServiceRequestsManagerTestCase : XCTestCase

@end

@implementation VDFServiceRequestsManagerTestCase

/*
@interface VDFServiceRequestsManager : VDFBaseManager <VDFHttpConnectorDelegate>

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration;

- (void)performRequestWithBuilder:(id<VDFRequestBuilder>)request;

- (void)clearRequestDelegate:(id<VDFUsersServiceDelegate>)requestDelegate;
*/


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMultipleSameRequests {
    // test performing multiple requests on manager with the same parameters
    
    id connectorMock = OCMClassMock([VDFHttpConnector class]);
    id configurationMock = OCMClassMock([VDFBaseConfiguration class]);
    id cacheManagerMock = OCMClassMock([VDFCacheManager class]);
    
    VDFServiceRequestsManager *managerToTest = [[VDFServiceRequestsManager alloc] initWithConfiguration:configurationMock cacheManager:cacheManagerMock];
    [managerToTest performRequestWithBuilder:nil];
    // Verify that expected methods were called

//    cacheManagerMock 
//    OCMVerify([connectorMock startCommunication]);
}

- (void)testPerformingCachedResponse {
    // test requests on manager where response is cached
}

- (void)testPerformOfRequest {
}

- (void)testRetryRequests {
}


@end

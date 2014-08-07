//
//  VDFCacheManagerTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFCacheManager.h"
#import "VDFBaseConfiguration.h"

extern void __gcov_flush();


@interface VDFCacheManagerTestCase : XCTestCase

@end

@implementation VDFCacheManagerTestCase

/*
- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration;

- (BOOL)isResponseCachedForRequest:(id<VDFRequest>)request;

- (id<NSCoding>)responseForRequest:(id<VDFRequest>)request;

- (void)cacheResponseObject:(id<NSCoding>)responseObject forRequest:(id<VDFRequest>)request;

- (void)clearExpiredCache;
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

- (void)testSimpleCachingFlow
{
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    configuration.cacheDirectoryPath = @"";
    configuration.applicationId = @"some test app id";
    
//    VDFCacheManager *managerToTest = [[VDFCacheManager alloc] initWithConfiguration:configuration];
//    managerToTest
}

@end

//
//  VDFUserResolveRequestBuilderTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 07/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFUserResolveRequestBuilder.h"
#import "VDFUserResolveOptions.h"
#import "VDFBaseConfiguration.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersServiceDelegateMock.h"

extern void __gcov_flush();

@interface VDFUserResolveRequestBuilderTestCase : XCTestCase
@property NSString *appId;
@property VDFUserResolveOptions *options;
@property VDFBaseConfiguration *config;
@property VDFUsersServiceDelegateMock *delegateMock;
@end

@implementation VDFUserResolveRequestBuilderTestCase

- (void)setUp
{
    self.appId = @"test app id for tests";
//    self.options = [[VDFUserResolveOptions alloc] initWithToken:@"asd" validateWithSms:YES];
    self.config = [[VDFBaseConfiguration alloc] init];
    self.delegateMock = [[VDFUsersServiceDelegateMock alloc] init];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// TODO tests
@end

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

@interface VDFRequestBuilderMock : NSObject <VDFRequestBuilder>
@end

@implementation VDFRequestBuilderMock
- (id<VDFRequestFactory>)factory { return nil; }
- (id)observer { return nil; }
- (id<VDFResponseParser>)responseParser { return nil; }
- (id<VDFRequestState>)requestState { return nil; }
- (id<VDFObserversContainer>)observersContainer { return nil; }
- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder { return NO; }
@end

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
    self.options = [[VDFUserResolveOptions alloc] initWithToken:@"asd" validateWithSms:YES];
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

- (void)testBuilderInitialization
{
    /*
    @property (nonatomic, strong) VDFUserResolveOptions *requestOptions;
    @property (nonatomic, readonly) NSString *urlEndpointQuery;
    @property (nonatomic, readonly) HTTPMethodType httpRequestMethodType;
    
    - (instancetype)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options withConfiguration:(VDFBaseConfiguration*)configuration delegate:(id<VDFUsersServiceDelegate>)delegate;
     
     - (id)observer;
    */
    
    VDFUserResolveRequestBuilder *requestBuilder = [[VDFUserResolveRequestBuilder alloc] initWithApplicationId:self.appId withOptions:self.options withConfiguration:self.config delegate:self.delegateMock];
    
    XCTAssertTrue([requestBuilder observer] == self.delegateMock, @"Observer is not set properly");
    XCTAssertTrue([requestBuilder.requestOptions isEqualToOptions:self.options], @"Request options is not set properly");
    XCTAssertEqual(requestBuilder.httpRequestMethodType, HTTPMethodPOST, @"HttpMethod should be POST");
    XCTAssertNotNil(requestBuilder.urlEndpointQuery, @"Endpoint query cannot be nil");
    XCTAssertNotEqualObjects(requestBuilder.urlEndpointQuery, @"", @"Endpoint query cannot be empty");
    
    
    
    
}

- (void)testIsEqualsToBuilder {
    
    id requestBuilder = [[VDFUserResolveRequestBuilder alloc] initWithApplicationId:self.appId withOptions:self.options withConfiguration:self.config delegate:self.delegateMock];
    
    XCTAssertTrue([requestBuilder isEqualToFactoryBuilder:requestBuilder], @"Factory should equal to it self.");
    XCTAssertFalse([requestBuilder isEqualToFactoryBuilder:nil], @"Factory should not equal to nil.");
    XCTAssertFalse([requestBuilder isEqualToFactoryBuilder:[[VDFRequestBuilderMock alloc] init]], @"Factory should not equal to builder of another type.");
}

@end

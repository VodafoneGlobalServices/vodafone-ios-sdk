//
//  VDFUserResolveRequestBuilderTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 07/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUserResolveRequestBuilder.h"
#import "VDFUserResolveRequestFactory.h"
#import "VDFUserResolveOptions.h"
#import "VDFBaseConfiguration.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFDIContainer.h"
#import "VDFConfigurationManager.h"
#import "VDFConsts.h"

extern void __gcov_flush();

@interface VDFUserResolveRequestBuilder ()
@property (nonatomic, strong) VDFUserResolveRequestFactory *internalFactory;
@end

@interface VDFUserResolveRequestBuilderTestCase : XCTestCase
@property VDFUserResolveRequestBuilder *builderToTest;
@property NSString *mockClientAppKey;
@property NSString *mockClientAppSecret;
@property NSString *mockBackendAppKey;
@property NSString *mockServiceBaseKey;
@property id mockOptions;
@property id mockConfiguration;
@property id mockDelegate;
@property id mockFactory;
@property id mockDIContainer;
@end

@implementation VDFUserResolveRequestBuilderTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.mockClientAppKey = @"fake mock client app key";
    self.mockClientAppSecret = @"fake mock client app secret";
    self.mockBackendAppKey = @"fake mock backend app key";
    self.mockServiceBaseKey = @"baseSeamlessID/url/path/";
    self.mockConfiguration = OCMClassMock([VDFBaseConfiguration class]);
    self.mockOptions = OCMClassMock([VDFUserResolveOptions class]);
    self.mockFactory = OCMClassMock([VDFUserResolveRequestFactory class]);
    
    [[[self.mockConfiguration stub] andReturn:self.mockClientAppKey] clientAppKey];
    [[[self.mockConfiguration stub] andReturn:self.mockClientAppSecret] clientAppSecret];
    [[[self.mockConfiguration stub] andReturn:self.mockBackendAppKey] backendAppKey];
    [[[self.mockConfiguration stub] andReturn:self.mockServiceBaseKey] serviceBasePath];
    [[[self.mockOptions stub] andReturn:self.mockOptions] copy];
    
    self.mockDIContainer = OCMClassMock([VDFDIContainer class]);
    [[[self.mockDIContainer stub] andReturn:self.mockConfiguration] resolveForClass:[VDFBaseConfiguration class]];
    
    self.builderToTest = [[VDFUserResolveRequestBuilder alloc] initWithOptions:self.mockOptions diContainer:self.mockDIContainer delegate:self.mockDelegate];
    self.builderToTest.internalFactory = self.mockFactory;
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetSessionToken {
    // mock
    NSString *newSessionToken = @"newSessionToken";
    
    // run
    self.builderToTest.sessionToken = newSessionToken;
    
    // assert
    NSString *newRetryUrlEndpoint = [self.mockServiceBaseKey stringByAppendingString:[NSString stringWithFormat:SERVICE_URL_PATH_SCHEME_CHECK_RESOLVE_STATUS, newSessionToken, self.mockBackendAppKey]];
    XCTAssertEqualObjects(self.builderToTest.sessionToken, newSessionToken, @"Session token after setting on builder should change.");
    XCTAssertEqualObjects(self.builderToTest.retryUrlEndpointQuery, newRetryUrlEndpoint, @"After session token changing the retry url request should change properly.");
}

- (void)testCreateCurrentHttpConnectorWithEtag {
    
    // mock
    id delegate = [[NSObject alloc] init];
    
    // stub
    self.builderToTest.eTag = @"some etag";
    
    // expect that the factory will be invoked to generate retry request object
    [[self.mockFactory expect] createRetryHttpConnectorWithDelegate:delegate];
    // expect that the factory wont be invoked to generate initial request object
    [[self.mockFactory reject] createHttpConnectorRequestWithDelegate:delegate];
    
    // run
    [self.builderToTest createCurrentHttpConnectorWithDelegate:delegate];
    
    //verify
    [self.mockFactory verify];
}

- (void)testCreateCurrentHttpConnectorWithoutEtag {
    
    // mock
    id delegate = [[NSObject alloc] init];
    id mockConfigurationManager = OCMClassMock([VDFConfigurationManager class]);
    
    // stub
    self.builderToTest.eTag = nil;
    [[[self.mockDIContainer stub] andReturn:mockConfigurationManager] resolveForClass:[VDFConfigurationManager class]];
    
    // expect that the factory wont be invoked to generate retry request object
    [[self.mockFactory reject] createRetryHttpConnectorWithDelegate:delegate];
    // expect that the factory will be invoked to generate initial request object
    [[self.mockFactory expect] createHttpConnectorRequestWithDelegate:delegate];
    // expect tha the configuration manager will be called to perform update check
    [[mockConfigurationManager expect] checkForUpdate];
    
    // run
    [self.builderToTest createCurrentHttpConnectorWithDelegate:delegate];
    
    //verify
    [self.mockFactory verify];
}

- (void)testIsEqualToFactoryBuilderWhenWrongData {
    
    // run & assert
    XCTAssertFalse([self.builderToTest isEqualToFactoryBuilder:nil], @"User resolve factory should not equal to nil.");
    
    // run & assert
    XCTAssertFalse([self.builderToTest isEqualToFactoryBuilder:(id<VDFRequestBuilder>)@"stubMock of different type"], @"User resolve factory should not equal to object of different type.");
}

- (void)testIsEqualToFactoryBuilderWhenBuildersNotEqual {
    
    // mock
    id mockBuilderDiffAppId = OCMClassMock([VDFUserResolveRequestBuilder class]);
    id mockBuilderDiffRequestOptions = OCMClassMock([VDFUserResolveRequestBuilder class]);
    VDFUserResolveOptions *differentRequestOptions = [[VDFUserResolveOptions alloc] initWithSmsValidation:YES];
    
    // stub
    [[[self.mockOptions stub] andReturnValue:OCMOCK_VALUE(YES)] isEqualToOptions:self.mockOptions];
    [[[mockBuilderDiffAppId stub] andReturn:@"some client app key different"] clientAppKey];
    [[[mockBuilderDiffAppId stub] andReturn:@"some client app secret different"] clientAppSecret];
    [[[mockBuilderDiffAppId stub] andReturn:@"some backend app key different"] backendAppKey];
    [[[mockBuilderDiffAppId stub] andReturn:self.mockOptions] requestOptions];
    [[[mockBuilderDiffRequestOptions stub] andReturn:self.mockClientAppKey] clientAppKey];
    [[[mockBuilderDiffRequestOptions stub] andReturn:self.mockClientAppSecret] clientAppSecret];
    [[[mockBuilderDiffRequestOptions stub] andReturn:self.mockBackendAppKey] backendAppKey];
    [[[mockBuilderDiffRequestOptions stub] andReturn:differentRequestOptions] requestOptions];

    // run & assert
    XCTAssertFalse([self.builderToTest isEqualToFactoryBuilder:mockBuilderDiffAppId], @"Equality check of builder with different clientAppKey should return false.");
    XCTAssertFalse([self.builderToTest isEqualToFactoryBuilder:mockBuilderDiffRequestOptions], @"Equality check of builder with different request options should return false.");
}

- (void)testIsEqualToFactoryBuilderWhenBuilderEqual {
    
    // mock
    id mockSameBuilder = [[VDFUserResolveRequestBuilder alloc] initWithOptions:self.mockOptions diContainer:self.mockDIContainer delegate:nil];
    
    // stub
    [[[self.mockOptions stub] andReturnValue:OCMOCK_VALUE(YES)] isEqualToOptions:self.mockOptions];
    
    // run & assert
    XCTAssertTrue([self.builderToTest isEqualToFactoryBuilder:mockSameBuilder], @"Builder wit the same application Id and request options should equal.");
}

@end

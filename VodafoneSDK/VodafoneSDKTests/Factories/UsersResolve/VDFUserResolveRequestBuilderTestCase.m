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

extern void __gcov_flush();

@interface VDFUserResolveRequestBuilder ()
@property (nonatomic, strong) VDFUserResolveRequestFactory *internalFactory;
@end

@interface VDFUserResolveRequestBuilderTestCase : XCTestCase
@property VDFUserResolveRequestBuilder *builderToTest;
@property NSString *mockAppId;
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
    self.mockAppId = @"fake mock app id";
    self.mockConfiguration = OCMClassMock([VDFBaseConfiguration class]);
    self.mockOptions = OCMClassMock([VDFUserResolveOptions class]);
    self.mockFactory = OCMClassMock([VDFUserResolveRequestFactory class]);
    
    [[[self.mockOptions stub] andReturn:self.mockOptions] copy];
    
    self.mockDIContainer = OCMClassMock([VDFDIContainer class]);
    [[[self.mockDIContainer stub] andReturn:self.mockConfiguration] resolveForClass:[VDFBaseConfiguration class]];
    
    self.builderToTest = [[VDFUserResolveRequestBuilder alloc] initWithApplicationId:self.mockAppId withOptions:self.mockOptions diContainer:self.mockDIContainer delegate:self.mockDelegate];
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
    id newSessionToken = @"newSessionToken";
    // run
    self.builderToTest.sessionToken = newSessionToken;
    // assert
    XCTAssertEqualObjects(self.builderToTest.sessionToken, newSessionToken, @"Session token after setting on builder should change.");
    XCTAssertEqualObjects(self.builderToTest.retryUrlEndpointQuery, @"/users/tokens/checkstatus/newSessionToken", @"After session token changing the retry rul request should change properly.");
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
    
    // stub
    self.builderToTest.eTag = nil;
    
    // expect that the factory wont be invoked to generate retry request object
    [[self.mockFactory reject] createRetryHttpConnectorWithDelegate:delegate];
    // expect that the factory will be invoked to generate initial request object
    [[self.mockFactory expect] createHttpConnectorRequestWithDelegate:delegate];
    
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
    VDFUserResolveOptions *differentRequestOptions = [[VDFUserResolveOptions alloc] initWithValidateWithSms:YES];
    
    // stub
    [[[self.mockOptions stub] andReturnValue:OCMOCK_VALUE(YES)] isEqualToOptions:self.mockOptions];
    [[[mockBuilderDiffAppId stub] andReturn:@"some app id different"] applicationId];
    [[[mockBuilderDiffAppId stub] andReturn:self.mockOptions] requestOptions];
    [[[mockBuilderDiffRequestOptions stub] andReturn:self.mockAppId] applicationId];
    [[[mockBuilderDiffRequestOptions stub] andReturn:differentRequestOptions] requestOptions];

    // run & assert
    XCTAssertFalse([self.builderToTest isEqualToFactoryBuilder:mockBuilderDiffAppId], @"Equality check of builder with different appId should return false.");
    XCTAssertFalse([self.builderToTest isEqualToFactoryBuilder:mockBuilderDiffRequestOptions], @"Equality check of builder with different request options should return false.");
}

- (void)testIsEqualToFactoryBuilderWhenBuilderEqual {
    
    // mock
    id mockSameBuilder = [[VDFUserResolveRequestBuilder alloc] initWithApplicationId:self.mockAppId withOptions:self.mockOptions diContainer:nil delegate:nil];
    
    // stub
    [[[self.mockOptions stub] andReturnValue:OCMOCK_VALUE(YES)] isEqualToOptions:self.mockOptions];
    
    // run & assert
    XCTAssertTrue([self.builderToTest isEqualToFactoryBuilder:mockSameBuilder], @"Builder wit the same application Id and request options should equal.");
}

- (void)testDidReceivedOAuthTokenWhenErrorOccuredOrOAuthTokenNotProvided {
    
    // mock
    VDFOAuthTokenResponse *tokenMock = [[VDFOAuthTokenResponse alloc] init];
    self.builderToTest.oAuthToken = nil;
    
    // run & assert
    [self.builderToTest didReceivedOAuthToken:nil withError:nil];
    XCTAssertNil(self.builderToTest.oAuthToken, @"OAuth token should not change when didUpdate was invoked with nil oauthToken");
    
    // run & assert
    [self.builderToTest didReceivedOAuthToken:tokenMock withError:[[NSError alloc] init]];
    XCTAssertNil(self.builderToTest.oAuthToken, @"OAuth token should not change when didUpdate was invoked with error");
    
    // run & assert
    [self.builderToTest didReceivedOAuthToken:nil withError:[[NSError alloc] init]];
    XCTAssertNil(self.builderToTest.oAuthToken, @"OAuth token should not change when didUpdate was invoked with nil oauthToken and error");
}

- (void)testDidReceivedOAuthTokenWhenTokenProvidedWithoutError {
    
    // mock
    VDFOAuthTokenResponse *tokenMock = [[VDFOAuthTokenResponse alloc] init];
    self.builderToTest.oAuthToken = nil;
    
    // run & assert
    [self.builderToTest didReceivedOAuthToken:tokenMock withError:nil];
    XCTAssertEqualObjects(self.builderToTest.oAuthToken, tokenMock, @"OAuth token should change when didReceivedOAuthToken was called with valid token and no error.");
}

@end

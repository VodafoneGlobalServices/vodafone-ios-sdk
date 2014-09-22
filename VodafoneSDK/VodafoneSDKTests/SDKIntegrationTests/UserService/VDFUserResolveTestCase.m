//
//  VDFUserResolveTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 22/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OCMock/OCMock.h>
#import "VDFUsersService.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUserTokenDetails.h"
#import "VDFSettings.h"

extern void __gcov_flush();

@interface VDFUsersService ()
- (NSError*)checkPotentialHAPResolveError;
- (NSError*)updateResolveOptionsAndCheckMSISDNForError:(VDFUserResolveOptions*)options;
@end

@interface VDFUserResolveTestCase : XCTestCase
@property NSString* backendId;
@property NSString* appId;
@property NSString* appSecret;
@property id serviceToTest;
@end

@implementation VDFUserResolveTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // mock
    self.backendId = @"someBackendId";
    self.appId = @"someAppId";
    self.appSecret = @"someAppSecret";
    self.serviceToTest = OCMPartialMock([VDFUsersService sharedInstance]);
    
    // stub oAuthToken response:
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path hasSuffix:@"oauth/access-token"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:[@"{ \"access_token\": \"wp7d1kLsrpxOuK3vzIMmRmPzmsJ6\", \"token_type\": \"Bearer\", \"expires_in\": \"3599\" }" dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:200
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
    
    // initialize SDK:
    [VDFSettings initializeWithParams:@{VDFClientAppKeySettingKey: self.appId,
                                        VDFClientAppSecretSettingKey: self.appSecret,
                                        VDFBackendAppKeySettingKey: self.backendId}];}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testResolveWithoutSMSValidation {
    
    // mock
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.path hasSuffix:@"users/tokens"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        // Stub it with our "wsresponse.json" stub file
        return [OHHTTPStubsResponse responseWithData:[@"{ \"acr\": \"someACR\", \"expiresIn\": 60000, \"tokenId\": \"someTokenId\" }" dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:201
                                             headers:@{@"Content-Type":@"application/json"}];
    }];
    id mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub the sim card checking
    [[[self.serviceToTest stub] andReturn:nil] checkPotentialHAPResolveError];
    
    
    // expect that the delegate object will be invoked correctly:
    [[mockDelegate expect] didReceivedUserDetails:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFUserTokenDetails *tokenDetails = (VDFUserTokenDetails*)obj;
        
        return [tokenDetails.token isEqualToString:@"someTokenId"]
        && [tokenDetails.acr isEqualToString:@"someACR"]
        && tokenDetails.expiresIn != nil;
        
    }] withError:[OCMArg isNil]];
    
    
    // run
    VDFUserResolveOptions *options = [[VDFUserResolveOptions alloc] initWithSmsValidation:NO];
    [self.serviceToTest retrieveUserDetails:options delegate:mockDelegate];
    
    
    // verify
    [mockDelegate verifyWithDelay:4];
}

@end

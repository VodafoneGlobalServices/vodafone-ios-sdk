//
//  VDFUserResolveRequestStateTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFUserResolveRequestState.h"
#import "VDFUserResolveOptions.h"
#import "VDFUserTokenDetails.h"

extern void __gcov_flush();

@interface VDFUserResolveRequestStateTestCase : XCTestCase

@property (nonatomic, strong) NSString *initialSessionToken;
@property (nonatomic, strong) VDFUserResolveOptions *options;
@property (nonatomic, strong) VDFUserResolveRequestState *requestState;
@property (nonatomic, strong) NSMutableDictionary *validTokenDetailsJson;

- (void)checkIsCurrentlyInitialStateWithMessagePrefix:(NSString*)messagePrefix;

@end

@implementation VDFUserResolveRequestStateTestCase
/*
- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.initialSessionToken = @"someInitialToken";
    self.options = [[VDFUserResolveOptions alloc] validateWithSms:NO];
    self.requestState = [[VDFUserResolveRequestState alloc] initWithBuilder:];
    
    self.validTokenDetailsJson = [NSMutableDictionary dictionaryWithDictionary:
                                  @{ @"resolved": [NSNumber numberWithBool:NO],
                                     @"stillRunning": [NSNumber numberWithBool:YES],
                                     @"source": @"some source",
                                     @"token": @"some changed token",
                                     @"expires": @"2014-08-08T12:57:32+02:00",
                                     @"tetheringConflict": [NSNumber numberWithBool:YES],
                                     @"validated": [NSNumber numberWithBool:YES]
                                     }];
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsInitialStateProper {
    [self checkIsCurrentlyInitialStateWithMessagePrefix:@"New created objects"];
}

- (void)testIsStateChangeOnResponseCode {
    for (int i=0; i<600; i++) {
        [self.requestState updateWithHttpResponseCode:i]; // setting response code should not may any impact on state
        
        // Making asserts:
        [self checkIsCurrentlyInitialStateWithMessagePrefix:@"Setting response code"];
    }
}

- (void)testStateWithValidResponseUpdating {
    
    // performing operation:
    VDFUserTokenDetails *tokenDetials = [[VDFUserTokenDetails alloc] initWithJsonObject:self.validTokenDetailsJson];
    [self.validTokenDetailsJson setObject:[NSNumber numberWithBool:YES] forKey:@"stillRunning"];
    [self.requestState updateWithParsedResponse:tokenDetials];
    
    // Assertions:
    XCTAssertTrue([self.requestState isRetryNeeded], @"After updating with parsed response with stillRuningFlag seted to true the isRetryNeeded property of state should be true.");
    XCTAssertEqualObjects([self.requestState lastResponseExpirationDate], [NSDate dateWithTimeIntervalSince1970:0], @"After updating with parsed response the last response expiration date should not change and points to date from past.");
    
    // check is initialized options corresponds to new session token:
    XCTAssertEqualObjects(self.options.token, tokenDetials.token, @"After updating with new sesion token the token from initialization object should change.");
    
    // performing operation:
    [self.validTokenDetailsJson setObject:[NSNumber numberWithBool:NO] forKey:@"stillRunning"];
    [self.requestState updateWithParsedResponse:[[VDFUserTokenDetails alloc] initWithJsonObject:self.validTokenDetailsJson]];
    
    // Assertions:
    XCTAssertFalse([self.requestState isRetryNeeded], @"After updating with parsed response with stillRuningFlag seted to false the isRetryNeeded property of state should be false.");
}

- (void)testStateWithInvalidResponseUpdate {
    // nil:
    XCTAssertNoThrow([self.requestState updateWithParsedResponse:nil], @"Update with nil should not throw exceptions");
    [self checkIsCurrentlyInitialStateWithMessagePrefix:@"Updating with nil object"];
    
    // another type object:
    XCTAssertNoThrow([self.requestState updateWithParsedResponse:@"dummy string"], @"Updating with diffrent type object should not throw exceptions");
    [self checkIsCurrentlyInitialStateWithMessagePrefix:@"Updating with diffrent type object"];
}

- (void)checkIsCurrentlyInitialStateWithMessagePrefix:(NSString*)messagePrefix {
    
    XCTAssertTrue([self.requestState isRetryNeeded], @"%@ should not change initial isRetryNeeded=true flag.", messagePrefix);
    XCTAssertNotEqualObjects([self.requestState lastResponseExpirationDate], [NSDate dateWithTimeIntervalSinceNow:3600*24], @"%@ should not change the default value of one day.", messagePrefix); // TODO after moving this value to the configutation please update this test case
    
    // check is initialized options session token do not changed:
    XCTAssertEqualObjects(self.options.token, self.initialSessionToken, @"%@ should not change the session token in initial properties.", messagePrefix);
}
*/
@end

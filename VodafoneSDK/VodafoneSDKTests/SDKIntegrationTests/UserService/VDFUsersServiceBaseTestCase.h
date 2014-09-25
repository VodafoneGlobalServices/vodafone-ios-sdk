//
//  VDFUserResolve.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 23/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

@class VDFBaseConfiguration;

@interface VDFUsersServiceBaseTestCase : XCTestCase
@property id serviceToTest;
@property id mockDelegate;
@property NSString *backendId;
@property NSString *appId;
@property NSString *appSecret;
@property NSString *oAuthToken;
@property NSString *acr;
@property NSString *sessionToken;
@property NSString *etag;
@property NSString *msisdn;
@property NSString *market;
@property BOOL smsValidation;
@property NSString *smsCode;


#pragma mark -
#pragma mark - requestFilters
- (OHHTTPStubsTestBlock)filterOAuthRequest;

- (OHHTTPStubsTestBlock)filterResolveRequestWithMSISDN;
- (OHHTTPStubsTestBlock)filterResolveRequestWithSmsValidation;

- (OHHTTPStubsTestBlock)filterCheckStatusRequest;

- (OHHTTPStubsTestBlock)filterGeneratePinRequest;

- (OHHTTPStubsTestBlock)filterValidatePinRequest;


#pragma mark -
#pragma mark - responses
- (OHHTTPStubsResponseBlock)responseEmptyWithCode:(int)statusCode;

- (OHHTTPStubsResponseBlock)responseOAuthSuccessExpireInSeconds:(NSInteger)expireInSeconds;
- (OHHTTPStubsResponseBlock)responseOAuthTokenExpired;
- (OHHTTPStubsResponseBlock)responseOAuthOpCoNotValidError;
- (OHHTTPStubsResponseBlock)responseOAuthScopeNotValidError;

- (OHHTTPStubsResponseBlock)responseResolve201;
- (OHHTTPStubsResponseBlock)responseResolve302NotFinishedAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseResolve302SmsRequiredAndRetryAfterMs:(NSInteger)retryAfterMs;


- (OHHTTPStubsResponseBlock)responseCheckStatus302NotFinishedAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus302SmsRequiredAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus304NotModifiedAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus200;

- (OHHTTPStubsResponseBlock)responseValidatePin200;

- (id<OHHTTPStubsDescriptor>)stubRequest:(OHHTTPStubsTestBlock)requestFilter
                       withResponsesList:(NSArray*)responses;
@end

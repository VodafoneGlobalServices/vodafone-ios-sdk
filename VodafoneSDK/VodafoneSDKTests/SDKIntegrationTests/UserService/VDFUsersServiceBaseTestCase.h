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
- (OHHTTPStubsResponseBlock)responseEmpty200;
- (OHHTTPStubsResponseBlock)responseEmpty404;
- (OHHTTPStubsResponseBlock)responseEmpty500;
- (OHHTTPStubsResponseBlock)responseEmpty400;
- (OHHTTPStubsResponseBlock)responseEmpty401;
- (OHHTTPStubsResponseBlock)responseEmpty403;
- (OHHTTPStubsResponseBlock)responseEmpty409;

- (OHHTTPStubsResponseBlock)responseOAuthSuccessExpireInSeconds:(NSInteger)expireInSeconds;
- (OHHTTPStubsResponseBlock)responseOAuthTokenExpired;
- (OHHTTPStubsResponseBlock)responseOAuthOpCoNotValidError;
- (OHHTTPStubsResponseBlock)responseOAuthScopeNotValidError;

- (OHHTTPStubsResponseBlock)responseResolve201;
- (OHHTTPStubsResponseBlock)responseResolve302NotFinished;
- (OHHTTPStubsResponseBlock)responseResolve302SmsRequired;


- (OHHTTPStubsResponseBlock)responseCheckStatus302NotFinished;
- (OHHTTPStubsResponseBlock)responseCheckStatus302SmsRequired;
- (OHHTTPStubsResponseBlock)responseCheckStatus200;

- (OHHTTPStubsResponseBlock)responseValidatePin200;

- (id<OHHTTPStubsDescriptor>)stubRequest:(OHHTTPStubsTestBlock)requestFilter
                       withResponsesList:(NSArray*)responses;
@end

//
//  VDFUserResolve.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 23/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "VDFError.h"
#import "VDFUserTokenDetails.h"
#import "VDFMessageLogger.h"

@class VDFBaseConfiguration, VDFUsersService;

@interface VDFUsersServiceBaseTestCase : XCTestCase <VDFMessageLogger>
@property VDFUsersService *service;
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

#pragma mark -
#pragma mark - stub
- (id<OHHTTPStubsDescriptor>)stubRequest:(OHHTTPStubsTestBlock)requestFilter
                       withResponsesList:(NSArray*)responses;


#pragma mark -
#pragma mark - expect methods
- (void)rejectAnyNotHandledHttpCall;

- (void)expectDidReceivedUserDetailsWithErrorCode:(VDFErrorCode)errorCode;
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus;
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus onSuccessExecution:(void(^)(VDFUserTokenDetails *details))onSuccess;

- (void)expectDidSMSPinRequestedWithSuccess:(BOOL)isSuccess;
- (void)expectDidSMSPinRequestedWithSuccess:(BOOL)isSuccess onSuccessExecution:(void(^)())onSuccess;
- (void)expectDidSMSPinRequestedWithErrorCode:(VDFErrorCode)errorCode;

- (void)expectDidValidatedSMSWithSuccess:(BOOL)isSuccess;
- (void)expectDidValidatedSMSWithErrorCode:(VDFErrorCode)errorCode;


@end

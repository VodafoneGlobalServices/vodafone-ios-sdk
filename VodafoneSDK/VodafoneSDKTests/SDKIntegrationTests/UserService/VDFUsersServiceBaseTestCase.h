//
//  VDFUserResolve.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 23/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFTestCase.h"
#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "VDFError.h"
#import "VDFUserTokenDetails.h"
#import "VDFMessageLogger.h"

@class VDFBaseConfiguration, VDFUsersService;

@interface VDFUsersServiceBaseTestCase : VDFTestCase <VDFMessageLogger>
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
@property id<OHHTTPStubsDescriptor> defaultConfigUpdateStub;
@property NSNumber *stubConfigUpdate;


#pragma mark -
#pragma mark - requestFilters
- (OHHTTPStubsTestBlock)filterOAuthRequest;

- (OHHTTPStubsTestBlock)filterResolveRequestWithMSISDN;
- (OHHTTPStubsTestBlock)filterResolveRequestWithSmsValidation;

- (OHHTTPStubsTestBlock)filterCheckStatusRequest;

- (OHHTTPStubsTestBlock)filterGeneratePinRequest;

- (OHHTTPStubsTestBlock)filterValidatePinRequest;
- (OHHTTPStubsTestBlock)filterValidatePinRequestWithCode:(NSString*)code;

- (OHHTTPStubsTestBlock)filterUpdateConfigurationRequest;


#pragma mark -
#pragma mark - responses
- (OHHTTPStubsResponseBlock)responseEmptyWithCode:(int)statusCode;

- (OHHTTPStubsResponseBlock)responseOAuthSuccessExpireInSeconds:(NSInteger)expireInSeconds;
- (OHHTTPStubsResponseBlock)responseOAuthTokenExpired;
- (OHHTTPStubsResponseBlock)responseOAuthOpCoNotValidError;
- (OHHTTPStubsResponseBlock)responseOAuthScopeNotValidError;

- (OHHTTPStubsResponseBlock)responseResolve201;
- (OHHTTPStubsResponseBlock)responseResolve302NotFinishedAndRetryAfterDefaultMs;
- (OHHTTPStubsResponseBlock)responseResolve302SmsRequiredAndRetryAfterDefaultMs;
- (OHHTTPStubsResponseBlock)responseResolve302NotFinishedAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseResolve302SmsRequiredAndRetryAfterMs:(NSInteger)retryAfterMs;


- (OHHTTPStubsResponseBlock)responseCheckStatus302NotFinishedAndRetryAfterDefaultMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus302SmsRequiredAndRetryAfterDefaultMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus304NotModifiedAndRetryAfterDefaultMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus302NotFinishedAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus302SmsRequiredAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus304NotModifiedAndRetryAfterMs:(NSInteger)retryAfterMs;
- (OHHTTPStubsResponseBlock)responseCheckStatus200;

- (OHHTTPStubsResponseBlock)responseValidatePin200;

- (OHHTTPStubsResponseBlock)responseUpdateConfiguration200WithMaxAge:(int)maxAge;

#pragma mark -
#pragma mark - stub
- (id<OHHTTPStubsDescriptor>)stubRequest:(OHHTTPStubsTestBlock)requestFilter
                       withResponsesList:(NSArray*)responses;
- (id<OHHTTPStubsDescriptor>)stubRequest:(OHHTTPStubsTestBlock)requestFilter
                       withResponsesList:(NSArray*)responses
                             requestTime:(NSTimeInterval)requestTime
                            responseTime:(NSTimeInterval)responseTime;


#pragma mark -
#pragma mark - expect methods
- (void)rejectAnyNotHandledHttpCall;

- (void)rejectAnyOtherDelegateCall;

- (void)expectDidReceivedUserDetailsWithErrorCode:(VDFErrorCode)errorCode;
- (void)expectDidReceivedUserDetailsWithErrorCode:(VDFErrorCode)errorCode onMatchingExecution:(void(^)())onMatch;
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus;
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus onSuccessExecution:(void(^)(VDFUserTokenDetails *details))onSuccess;

- (void)expectDidSMSPinRequestedWithSuccess:(BOOL)isSuccess;
- (void)expectDidSMSPinRequestedWithSuccess:(BOOL)isSuccess onSuccessExecution:(void(^)())onSuccess;
- (void)expectDidSMSPinRequestedWithErrorCode:(VDFErrorCode)errorCode;
- (void)expectDidSMSPinRequestedWithErrorCode:(VDFErrorCode)errorCode onSuccessExecution:(void(^)())onSuccess;

- (void)expectDidValidatedSMSWithSuccess;
- (void)expectDidValidatedSMSWithErrorCode:(VDFErrorCode)errorCode;
- (void)expectDidValidatedSMSCode:(NSString*)code withErrorCode:(VDFErrorCode)errorCode;
- (void)expectDidValidatedSMSCode:(NSString*)code withErrorCode:(VDFErrorCode)errorCode onSuccessExecution:(void(^)())onSuccess;
- (void)expectDidValidatedSuccessfulSMSCode:(NSString*)code;


@end

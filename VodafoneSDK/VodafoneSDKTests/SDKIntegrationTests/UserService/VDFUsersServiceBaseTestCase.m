//
//  VDFUsersServiceBaseTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 23/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersServiceBaseTestCase.h"
#import <OCMock/OCMock.h>
#import "VDFUsersService.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUserTokenDetails.h"
#import "VDFSettings.h"
#import "VDFConsts.h"
#import "VDFDeviceUtility.h"
#import "VDFSmsValidationResponse.h"
#import "VDFNetworkReachability.h"
#import "VDFSettings+Internal.h"
#import "VDFDIContainer.h"

extern void __gcov_flush();

@interface VDFUsersService ()
- (NSError*)checkPotentialHAPResolveError;
- (NSError*)updateResolveOptionsAndCheckMSISDNForError:(VDFUserResolveOptions*)options;

- (void)resetOneInstanceToken;
+ (VDFNetworkReachability*)reachabilityForInternetConnection;
@end

@interface OHHTTPStubsDescriptor : NSObject <OHHTTPStubsDescriptor>
@property(atomic, copy) OHHTTPStubsTestBlock testBlock;
@property(atomic, copy) OHHTTPStubsResponseBlock responseBlock;
@end

@implementation VDFUsersServiceBaseTestCase

- (void)setUp
{
    [super setUp];
    
    [[VDFUsersService sharedInstance] resetOneInstanceToken];
    [VDFSettings initialize];
    
    self.backendId = @"someBackendId";
    self.appId = @"someAppId";
    self.appSecret = @"someAppSecret";
    self.oAuthToken = @"wp7d1kLsrpxOuK3vzIMmRmPzmsJ6";
    self.acr = @"someACRvalue";
    self.sessionToken = @"asfw32wer323eqrwfsw34";
    self.etag = @"someEtag";
    self.msisdn = @"49123123123";
    self.market = @"DE";
    self.smsValidation = YES;
    self.smsCode = @"1234";
    
    // initialize SDK:
    [VDFSettings initializeWithParams:@{ VDFClientAppKeySettingKey: self.appId,
                                         VDFClientAppSecretSettingKey: self.appSecret,
                                         VDFBackendAppKeySettingKey: self.backendId }];
    
    self.serviceToTest = OCMPartialMock([VDFUsersService sharedInstance]);
    self.mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub the sim card checking
    [[[self.serviceToTest stub] andReturn:nil] checkPotentialHAPResolveError];
    
    // stub network checking class:
    id mockDeviceUtility = OCMClassMock([VDFDeviceUtility class]);
    [[[mockDeviceUtility stub] andReturnValue:OCMOCK_VALUE(VDFNetworkAvailableViaGSM)] checkNetworkTypeAvailability];
    [[VDFSettings globalDIContainer] registerInstance:mockDeviceUtility forClass:[VDFDeviceUtility class]];
}

- (void)tearDown
{
    __gcov_flush();
    
    [OHHTTPStubs removeAllStubs];
    [self.serviceToTest stopMocking];
    [[VDFUsersService sharedInstance] cancelRetrieveUserDetails];
    [[VDFUsersService sharedInstance] resetOneInstanceToken];
    [VDFSettings initialize];
    
    [super tearDown];
}

#pragma mark -
#pragma mark - helper methods
- (BOOL)checkStandardRequiredHeaders:(NSURLRequest*)request {
    
//    static NSString *lastTransactionId = @"";
    
    NSDictionary *headers = [request allHTTPHeaderFields];
//    NSString *mcc = [VDFDeviceUtility simMCC];
    BOOL result = [[headers objectForKey:HTTP_HEADER_USER_AGENT] isEqualToString:[NSString stringWithFormat:@"VFSeamlessID SDK/iOS (v%@)", [VDFSettings sdkVersion]]]
    && [[headers objectForKey:HTTP_HEADER_AUTHORIZATION] isEqualToString:[NSString stringWithFormat:@"Bearer %@", self.oAuthToken]]
    /*&& [[headers objectForKey:@"x-vf-trace-subject-id"] isEqualToString:[VDFDeviceUtility deviceUniqueIdentifier]]
    && (mcc == nil || [[headers objectForKey:@"x-vf-trace-subject-region"] isEqualToString:mcc])*/
    && [[headers objectForKey:@"x-vf-trace-source"] isEqualToString:[NSString stringWithFormat:@"iOS-%@-%@", self.appId, self.backendId]];
    

    // it is commented because the OHHTPStubs are making a lot of the same requests, so this last transactions id cannot be check that way
//    if(result) {
//        // check is transaction id is different on each request
//        result = ![[headers objectForKey:@"x-vf-trace-transaction-id"] isEqualToString:lastTransactionId];
//        if(result) {
//            lastTransactionId = [headers objectForKey:@"x-vf-trace-transaction-id"];
//        }
//    }
    
    return result;
}


#pragma mark -
#pragma mark - requestFilters
- (OHHTTPStubsTestBlock)filterOAuthRequest {
    return ^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString hasSuffix:@"oauth/access-token"];
    };
}

- (OHHTTPStubsTestBlock)filterResolveRequestWithMSISDN {
    return ^BOOL(NSURLRequest *request) {
        if([request.URL.absoluteString hasSuffix:[NSString stringWithFormat:@"seamless-id/users/tokens?backendId=%@", self.backendId]]
           && [[request HTTPMethod] isEqualToString:@"POST"]) {
            if([self checkStandardRequiredHeaders:request]) {
                // check body
                id jsonObject = [NSJSONSerialization JSONObjectWithData:[request HTTPBody] options:kNilOptions error:nil];
                return [[jsonObject objectForKey:@"msisdn"] isEqualToString:self.msisdn]
                    && [[jsonObject objectForKey:@"market"] isEqualToString:self.market];
            }
        }
        return NO;
    };
}

- (OHHTTPStubsTestBlock)filterResolveRequestWithSmsValidation {
    return ^BOOL(NSURLRequest *request) {
        if([request.URL.absoluteString hasSuffix:[NSString stringWithFormat:@"seamless-id/users/tokens?backendId=%@", self.backendId]]
           && [[request HTTPMethod] isEqualToString:@"POST"]) {
            if([self checkStandardRequiredHeaders:request]) {
                // check body
                id jsonObject = [NSJSONSerialization JSONObjectWithData:[request HTTPBody] options:kNilOptions error:nil];
                return [[jsonObject objectForKey:@"smsValidation"] isEqualToString:self.smsValidation ? @"true":@"false"];
            }
        }
        return NO;
    };
}

- (OHHTTPStubsTestBlock)filterCheckStatusRequest {
    return ^BOOL(NSURLRequest *request) {
        if([request.URL.absoluteString hasSuffix:[NSString stringWithFormat:@"seamless-id/users/tokens/%@?backendId=%@", self.sessionToken, self.backendId]]
           && [[request HTTPMethod] isEqualToString:@"GET"]) {
            return [self checkStandardRequiredHeaders:request];
        }
        return NO;
    };
}

- (OHHTTPStubsTestBlock)filterGeneratePinRequest {
    return ^BOOL(NSURLRequest *request) {
        if([request.URL.absoluteString hasSuffix:[NSString stringWithFormat:@"seamless-id/users/tokens/%@/pins?backendId=%@", self.sessionToken, self.backendId]]
           && [[request HTTPMethod] isEqualToString:@"GET"]) {
            return [self checkStandardRequiredHeaders:request];
        }
        return NO;
    };
}

- (OHHTTPStubsTestBlock)filterValidatePinRequest {
    return ^BOOL(NSURLRequest *request) {
        if([request.URL.absoluteString hasSuffix:[NSString stringWithFormat:@"seamless-id/users/tokens/%@/pins?backendId=%@", self.sessionToken, self.backendId]]
           && [[request HTTPMethod] isEqualToString:@"POST"]) {
            if([self checkStandardRequiredHeaders:request]) {
                // check body
                id jsonObject = [NSJSONSerialization JSONObjectWithData:[request HTTPBody] options:kNilOptions error:nil];
                return [[jsonObject objectForKey:@"code"] isEqualToString:self.smsCode];
            }
        }
        return NO;
    };
}


#pragma mark -
#pragma mark - responses

- (OHHTTPStubsResponseBlock)responseEmptyWithCode:(int)statusCode {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil statusCode:statusCode headers:@{}];
    };
}

- (OHHTTPStubsResponseBlock)responseOAuthSuccessExpireInSeconds:(NSInteger)expireInSeconds {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [[NSString stringWithFormat:@"{ \"access_token\": \"%@\", \"token_type\": \"Bearer\", \"expires_in\": \"%i\" }",
                  self.oAuthToken, expireInSeconds] dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:200
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON}];
    };
}

- (OHHTTPStubsResponseBlock)responseOAuthTokenExpired {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [@"{ \"id\": \"POL0002\", \"description\": \"Privacy Verification Failed -Authorization\" }" dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:403
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON}];
    };
}

- (OHHTTPStubsResponseBlock)responseOAuthOpCoNotValidError {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [@"{ \"id\": \"POL0001\", \"description\": \"Policy Error – Address Region Not Supported\" }" dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:403
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON}];
    };
}

- (OHHTTPStubsResponseBlock)responseOAuthScopeNotValidError {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [@"{ \"id\": \"POL0002\", \"description\": \"Privacy Verification Failed –Invalid Scope\" }" dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:403
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON}];
    };
}


- (OHHTTPStubsResponseBlock)responseResolve201 {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [[NSString stringWithFormat:@"{ \"acr\": \"%@\", \"expiresIn\": 60000, \"tokenId\": \"%@\" }",
                  self.acr, self.sessionToken] dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:201
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON}];
    };
}


- (OHHTTPStubsResponseBlock)responseResolve302NotFinishedAndRetryAfterMs:(NSInteger)retryAfterMs {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        OHHTTPStubsResponse *stub =
        [OHHTTPStubsResponse responseWithData:nil
                                   statusCode:302
                                      headers:@{HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@?backendId=%@",
                                                                       self.sessionToken, self.backendId],
                                                HTTP_HEADER_RETRY_AFTER: [NSString stringWithFormat:@"%i", retryAfterMs]}];
        stub.allowRedirects = NO;
        return stub;
    };
}

- (OHHTTPStubsResponseBlock)responseResolve302SmsRequiredAndRetryAfterMs:(NSInteger)retryAfterMs {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        OHHTTPStubsResponse *stub =
        [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:302
                                             headers:@{HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@/pins?backendId=%@",
                                                                              self.sessionToken, self.backendId],
                                                       HTTP_HEADER_RETRY_AFTER: [NSString stringWithFormat:@"%i", retryAfterMs]}];
        stub.allowRedirects = NO;
        return stub;
    };
}


- (OHHTTPStubsResponseBlock)responseCheckStatus302NotFinishedAndRetryAfterMs:(NSInteger)retryAfterMs {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        OHHTTPStubsResponse *stub =
        [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:302
                                             headers:@{HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@?backendId=%@",
                                                                              self.sessionToken, self.backendId],
                                                       HTTP_HEADER_RETRY_AFTER: [NSString stringWithFormat:@"%i", retryAfterMs],
                                                       HTTP_HEADER_ETAG: self.etag,
                                                       @"Cache-Control": @"must-revalidate"}];
        stub.allowRedirects = NO;
        return stub;
    };
}

- (OHHTTPStubsResponseBlock)responseCheckStatus302SmsRequiredAndRetryAfterMs:(NSInteger)retryAfterMs {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        OHHTTPStubsResponse *stub =
        [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:302
                                             headers:@{HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@/pins?backendId=%@",
                                                                              self.sessionToken, self.backendId],
                                                       HTTP_HEADER_RETRY_AFTER: [NSString stringWithFormat:@"%i", retryAfterMs],
                                                       HTTP_HEADER_ETAG: self.etag,
                                                       @"Cache-Control": @"must-revalidate"}];
        stub.allowRedirects = NO;
        return stub;
    };
}

- (OHHTTPStubsResponseBlock)responseCheckStatus304NotModifiedAndRetryAfterMs:(NSInteger)retryAfterMs {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:304
                                             headers:@{HTTP_HEADER_RETRY_AFTER: [NSString stringWithFormat:@"%i", retryAfterMs]}];
    };
}

- (OHHTTPStubsResponseBlock)responseCheckStatus200 {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [[NSString stringWithFormat:@"{ \"acr\": \"%@\", \"expiresIn\": 60000, \"tokenId\": \"%@\" }",
                  self.acr, self.sessionToken] dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:200
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON,
                                                       HTTP_HEADER_ETAG: self.etag}];
    };
}


- (OHHTTPStubsResponseBlock)responseValidatePin200 {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [[NSString stringWithFormat:@"{ \"acr\": \"%@\", \"expiresIn\": 60000, \"tokenId\": \"%@\" }",
                  self.acr, self.sessionToken] dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:200
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON}];
    };
}



#pragma mark -
#pragma mark - stubs


- (id<OHHTTPStubsDescriptor>)stubRequest:(OHHTTPStubsTestBlock)requestFilter
                            withResponsesList:(NSArray*)responses {
    
    // creating requests in reverse direction
    __block NSMutableArray *blocksArray = [NSMutableArray arrayWithCapacity:[responses count]];
    NSEnumerator *enumerator = [responses reverseObjectEnumerator];
    for (id element in enumerator) {
        [blocksArray addObject:element];
    }
    
    return [OHHTTPStubs stubRequestsPassingTest:requestFilter
                               withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                   OHHTTPStubsResponseBlock responseBlock = [[blocksArray lastObject] copy];
                                   
                                   if([blocksArray count] > 1) {
                                       // we have more then one waiting responses so we need to move next response:
                                       [blocksArray removeLastObject];
                                   }
                                   
                                   return responseBlock(request);
                               }];
}



#pragma mark -
#pragma mark - expect methods
- (void)rejectAnyOtherHttpCall {
    
    __block id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        for (OHHTTPStubsDescriptor *descriptor in [OHHTTPStubs allStubs]) {
            if(descriptor != stub &&  descriptor.testBlock(request)) {
                return NO;
            }
        }
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        XCTFail(@"This HTTP call is unhandled, but it should be.");
        return nil;
    }];
}

- (void)expectDidReceivedUserDetailsWithErrorCode:(VDFErrorCode)errorCode {
    
    [[self.mockDelegate expect] didReceivedUserDetails:nil withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        return [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
    }]];
}
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus {
    [self expectDidReceivedUserDetailsWithResolutionStatus:resolutionStatus onSuccessExecution:nil];
}
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus onSuccessExecution:(void(^)(VDFUserTokenDetails *details))onSuccess {
    
    [[self.mockDelegate expect] didReceivedUserDetails:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFUserTokenDetails *tokenDetails = (VDFUserTokenDetails*)obj;
        
        if(tokenDetails.resolutionStatus != resolutionStatus) {
            return NO;
        }
        
        BOOL result = NO;
        
        if(resolutionStatus == VDFResolutionStatusCompleted) {
            result = [tokenDetails.token isEqualToString:self.sessionToken]
            && [tokenDetails.acr isEqualToString:self.acr]
            && tokenDetails.expiresIn != nil;
        }
        else if(resolutionStatus == VDFResolutionStatusFailed) {
            result = tokenDetails.token == nil
            && tokenDetails.acr == nil
            && tokenDetails.expiresIn == nil;
        }
        else {
            result = [tokenDetails.token isEqualToString:self.sessionToken] // TODO if we get know that this should not be returned to the 3rd party app in this case
            && tokenDetails.acr == nil
            && tokenDetails.expiresIn == nil;
        }
        
        if(result && onSuccess != nil) {
            onSuccess(tokenDetails);
        }
        
        return result;
        
    }] withError:[OCMArg isNil]];
}

- (void)expectDidSMSPinRequestedWithSuccess:(BOOL)isSuccess {
    [self expectDidSMSPinRequestedWithSuccess:isSuccess onSuccessExecution:nil];
}

- (void)expectDidSMSPinRequestedWithSuccess:(BOOL)isSuccess onSuccessExecution:(void(^)())onSuccess {
    [[self.mockDelegate expect] didSMSPinRequested:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSNumber *isSuccessResult = (NSNumber*)obj;
        
        BOOL result = [isSuccessResult boolValue] == isSuccess;
        if(result && onSuccess != nil) {
            onSuccess();
        }
        return result;
    }] withError:[OCMArg isNil]];
}

- (void)expectDidSMSPinRequestedWithErrorCode:(VDFErrorCode)errorCode {
    [[self.mockDelegate expect] didSMSPinRequested:nil withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        return [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
    }]];
}

- (void)expectDidValidatedSMSWithSuccess:(BOOL)isSuccess {
    [[self.mockDelegate expect] didValidatedSMSToken:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFSmsValidationResponse *response = (VDFSmsValidationResponse*)obj;
        return [response.smsCode isEqualToString:self.smsCode] && response.isSucceded == isSuccess;
        
    }] withError:[OCMArg isNil]];
}

- (void)expectDidValidatedSMSWithErrorCode:(VDFErrorCode)errorCode {
    [[self.mockDelegate expect] didValidatedSMSToken:nil withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        return [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
    }]];
}


@end

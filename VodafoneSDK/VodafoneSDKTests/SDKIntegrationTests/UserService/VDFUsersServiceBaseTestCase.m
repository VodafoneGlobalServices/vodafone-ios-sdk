//
//  VDFUsersServiceBaseTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 23/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersServiceBaseTestCase.h"
#import <OCMock/OCMock.h>
#import <objc/runtime.h>
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
#import "VDFMessageLogger.h"

extern void __gcov_flush();

@interface VDFUsersService ()
@property (nonatomic, strong) VDFDIContainer *diContainer;

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

- (void)logMessage:(NSString*)message ofType:(VDFLogMessageType)logType {
    NSLog(@"%@", message);
}

- (void)setUp
{
    [super setUp];
    
    // before each test we should remove stored configuration file:
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : [NSString string];
    [[NSFileManager defaultManager] removeItemAtPath:[basePath stringByAppendingPathComponent:CONFIGURATION_CACHE_FILE_NAME] error:nil];
    
    
    NSLog(@"Number of still stubbed requests: %i.", [[OHHTTPStubs allStubs] count]);
    
    [[VDFUsersService sharedInstance] resetOneInstanceToken];
    [VDFSettings initialize];
    [VDFSettings subscribeDebugLogger:self];
    
    
    self.backendId = @"someBackendId";
    self.appId = @"someAppId";
    self.appSecret = @"someAppSecret";
    self.oAuthToken = @"wp7d1kLsrpxOuK3vzIMmRmPzmsJ6";
    self.acr = @"someACRvalue";
    self.sessionToken = @"asfw32wer323eqrwfsw34";
    self.etag = @"someEtag";
    self.msisdn = @"34678774201";
    self.market = @"DE";
    self.smsValidation = YES;
    self.smsCode = @"1234";
    
    // initialize SDK:
    [VDFSettings initializeWithParams:@{ VDFClientAppKeySettingKey: self.appId,
                                         VDFClientAppSecretSettingKey: self.appSecret,
                                         VDFBackendAppKeySettingKey: self.backendId }];
    
    
    self.service = [[VDFUsersService alloc] init];
    self.service.diContainer = [VDFSettings globalDIContainer];
    
    self.serviceToTest = OCMPartialMock(self.service);
    self.mockDelegate = OCMProtocolMock(@protocol(VDFUsersServiceDelegate));
    
    // stub the sim card checking
    [[[self.serviceToTest stub] andReturn:nil] checkPotentialHAPResolveError];
    
    // stub network checking class:
    id mockDeviceUtility = OCMClassMock([VDFDeviceUtility class]);
    [[[mockDeviceUtility stub] andReturnValue:OCMOCK_VALUE(VDFNetworkAvailableViaGSM)] checkNetworkTypeAvailability];
    [[VDFSettings globalDIContainer] registerInstance:mockDeviceUtility forClass:[VDFDeviceUtility class]];
    
    [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {
        NSLog(@"OHHTTPStubs onStubActivation for request url: %@, with stub: %@", request.URL.absoluteString, stub.name);
    }];
    
    
    // stubbing verify with delay from ocmock framework
    // because ocmock if has any registered rejects
    // waits whole specified time, so we need to change this flow
    // so it will wait for all expectation has occure and after that wait some steps to make sure that any reject has not invoked
    
    static dispatch_once_t swizzle_token;
    dispatch_once(&swizzle_token, ^{
        SEL originalSelector = @selector(verifyWithDelay:);
        SEL swizzledSelector = @selector(fake_verifyWithDelay:);
        
        Method originalMethod = class_getInstanceMethod([OCMockObject class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([VDFUsersServiceBaseTestCase class], swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod([OCMockObject class],
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod([OCMockObject class],
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });

    if(self.stubConfigUpdate == nil /*as default we stubbing it*/ || [self.stubConfigUpdate boolValue]) {
        // as default we need to handle configuration update calls:
        self.defaultConfigUpdateStub = [OHHTTPStubs stubRequestsPassingTest:[self filterUpdateConfigurationRequest]
                                                       withStubResponse:[self responseEmptyWithCode:304]];
    }

}

-(void)verify {}

- (void)fake_verifyWithDelay:(NSTimeInterval)delay {
    
    NSTimeInterval step = 0.1;
    while (delay > 0) {
        @try {
            [self verify];
            break;
        }
        @catch (NSException *e) {}
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:step]];
        delay -= step;
        step += 0.1;
    }
    [self verify];
}

- (void)tearDown
{
    __gcov_flush();
    
    [OHHTTPStubs removeStub:self.defaultConfigUpdateStub];
    
    NSLog(@"Number of still stubbed requests in tearDown: %i.", [[OHHTTPStubs allStubs] count]);
    
    if([[OHHTTPStubs allStubs] count] > 1) {
        // there should be only one stubbed response for any unhandled request
        // if not then it is an error
        XCTFail(@"There are still stubbed responses.");
    }
    
    [VDFSettings unsubscribeDebugLogger:self];
    [OHHTTPStubs removeAllStubs];
    [OHHTTPStubs onStubActivation:nil];
    [self.serviceToTest stopMocking];
    [self.mockDelegate stopMocking];
    __block id serviceToStop = self.service;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [serviceToStop cancelRetrieveUserDetails];
    });
    
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
   /* && [[headers objectForKey:@"x-vf-trace-source"] isEqualToString:[NSString stringWithFormat:@"iOS-%@-%@", self.appId, self.backendId]]*/;
    

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

- (OHHTTPStubsTestBlock)filterUpdateConfigurationRequest {
    return ^BOOL(NSURLRequest *request) {

        if([request.URL.absoluteString isEqualToString:[NSString stringWithFormat:SERVICE_URL_SCHEME_CONFIGURATION_UPDATE, 1]]
           && [[request HTTPMethod] isEqualToString:@"GET"]) {
            return YES;//[self checkStandardRequiredHeaders:request];
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
                [@"{ \"id\": \"POL0002\", \"description\": \"Privacy Verification Failed - Authorization\" }" dataUsingEncoding:NSUTF8StringEncoding]
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
                [@"{ \"id\": \"POL0002\", \"description\": \"Privacy Verification Failed – Invalid Scope\" }" dataUsingEncoding:NSUTF8StringEncoding]
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

- (OHHTTPStubsResponseBlock)responseUpdateConfiguration200WithMaxAge:(int)maxAge {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"validConfigurationUpdate.json", nil)
                                          statusCode:200
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON,
                                                       HTTP_HEADER_ETAG: @"asdasd123123",
                                                       HTTP_HEADER_LAST_MODIFIED: @"Thu, 09 Oct 2014 16:35:35 GMT",
                                                       @"Cache-Control": [NSString stringWithFormat:@"max-age=%i, must-revalidate", maxAge]}];
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
    
    __block id stub = [OHHTTPStubs stubRequestsPassingTest:requestFilter
                               withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                   OHHTTPStubsResponseBlock responseBlock = [[blocksArray lastObject] copy];
                                   
                                   if([blocksArray count] > 1) {
                                       // we have more then one waiting responses so we need to move next response:
                                       [blocksArray removeLastObject];
                                   }
                                   else {
                                       // it is last response, lets remove it
                                       [OHHTTPStubs removeStub:stub];
                                   }
                                   
                                   return [responseBlock(request) requestTime:0.01 responseTime:0.01]; // tere is not ever any immidetly response
                               }];
    [stub setName:[NSString stringWithFormat:@"%@", requestFilter]];
    return stub;
}



#pragma mark -
#pragma mark - expect methods
- (void)rejectAnyNotHandledHttpCall {
    
    __block id stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        for (OHHTTPStubsDescriptor *descriptor in [OHHTTPStubs allStubs]) {
            if(descriptor != stub &&  descriptor.testBlock(request)) {
                return NO;
            }
        }
        
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        XCTFail(@"This HTTP call is unhandled, but it should be. (%@)", request.URL.absoluteString);
        return nil;
    }];
}

- (void)rejectAnyOtherDelegateCall {
    [[self.mockDelegate reject] didReceivedUserDetails:[OCMArg any] withError:[OCMArg any]];
    [[self.mockDelegate reject] didSMSPinRequested:[OCMArg any] withError:[OCMArg any]];
    [[self.mockDelegate reject] didValidatedSMSToken:[OCMArg any] withError:[OCMArg any]];
}

- (void)expectDidReceivedUserDetailsWithErrorCode:(VDFErrorCode)errorCode {
    
    [[self.mockDelegate expect] didReceivedUserDetails:nil withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        BOOL isExpected = [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        NSLog(@"TEST_CASE_DEBUG expectDidReceivedUserDetailsWithErrorCode: - received error %@, %i -- is expected=%hhd", [error domain], [error code], isExpected);
        return isExpected;
        
    }]];
}
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus {
    [self expectDidReceivedUserDetailsWithResolutionStatus:resolutionStatus onSuccessExecution:nil];
}
- (void)expectDidReceivedUserDetailsWithResolutionStatus:(VDFResolutionStatus)resolutionStatus onSuccessExecution:(void(^)(VDFUserTokenDetails *details))onSuccess {
    
    [[self.mockDelegate expect] didReceivedUserDetails:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFUserTokenDetails *tokenDetails = (VDFUserTokenDetails*)obj;
        
        if(tokenDetails.resolutionStatus != resolutionStatus) {
            NSLog(@"TEST_CASE_DEBUG expectDidReceivedUserDetailsWithResolutionStatus: - received object %@ -- is expected=%hhd", tokenDetails, NO);
            return NO;
        }
        
        BOOL result = NO;
        
        if(resolutionStatus == VDFResolutionStatusCompleted) {
            result = [tokenDetails.token isEqualToString:self.sessionToken]
            && [tokenDetails.acr isEqualToString:self.acr]
            && tokenDetails.expiresIn != nil;
        }
        else {
            result = tokenDetails.token == nil
            && tokenDetails.acr == nil
            && tokenDetails.expiresIn == nil;
        }
        
        if(result && onSuccess != nil) {
            onSuccess(tokenDetails);
        }
        
        NSLog(@"TEST_CASE_DEBUG expectDidReceivedUserDetailsWithResolutionStatus: - received object %@ -- is expected=%hhd", tokenDetails, result);
        
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
        
        NSLog(@"TEST_CASE_DEBUG expectDidSMSPinRequestedWithSuccess: - received object %@ -- is expected=%hhd", isSuccessResult, result);
        
        if(result && onSuccess != nil) {
            onSuccess();
        }
        return result;
    }] withError:[OCMArg isNil]];
}

- (void)expectDidSMSPinRequestedWithErrorCode:(VDFErrorCode)errorCode {
    [[self.mockDelegate expect] didSMSPinRequested:@0 withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        BOOL result = [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
        NSLog(@"TEST_CASE_DEBUG expectDidSMSPinRequestedWithErrorCode: - received error %@, %i -- is expected=%hhd", [error domain], [error code], result);
        
        return result;
    }]];
}

- (void)expectDidValidatedSMSWithSuccess:(BOOL)isSuccess {
    [[self.mockDelegate expect] didValidatedSMSToken:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFSmsValidationResponse *response = (VDFSmsValidationResponse*)obj;
        BOOL result = [response.smsCode isEqualToString:self.smsCode] && response.isSucceded == isSuccess;
        
        NSLog(@"TEST_CASE_DEBUG expectDidSMSPinRequestedWithSuccess: - received object %@ -- is expected=%hhd", response, result);
        
        return result;
    }] withError:[OCMArg isNil]];
}

- (void)expectDidValidatedSMSWithErrorCode:(VDFErrorCode)errorCode {
    [[self.mockDelegate expect] didValidatedSMSToken:[OCMArg checkWithBlock:^BOOL(id obj) {
        
        VDFSmsValidationResponse *response = (VDFSmsValidationResponse*)obj;
        BOOL result = [response.smsCode isEqualToString:self.smsCode] && !response.isSucceded;
        
        return result;
    }] withError:[OCMArg checkWithBlock:^BOOL(id obj) {
        NSError *error = (NSError*)obj;
        BOOL result = [[error domain] isEqualToString:VodafoneErrorDomain] && [error code] == errorCode;
        
        NSLog(@"TEST_CASE_DEBUG expectDidSMSPinRequestedWithErrorCode: - received error %@, %i -- is expected=%hhd", [error domain], [error code], result);
        
        return result;
    }]];
}


@end

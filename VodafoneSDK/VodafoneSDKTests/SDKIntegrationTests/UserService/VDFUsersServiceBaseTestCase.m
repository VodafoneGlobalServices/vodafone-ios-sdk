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

extern void __gcov_flush();

@implementation VDFUsersServiceBaseTestCase

- (void)setUp
{
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
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

#pragma mark -
#pragma mark - helper methods
- (BOOL)checkStandardRequiredHeaders:(NSURLRequest*)request {
    
    static NSString *lastTransactionId = @"";
    
    NSDictionary *headers = [request allHTTPHeaderFields];
    NSString *mcc = [VDFDeviceUtility simMCC];
    BOOL result = [[headers objectForKey:HTTP_HEADER_USER_AGENT] isEqualToString:[NSString stringWithFormat:@"VFSeamlessID SDK/iOS (v%@)", [VDFSettings sdkVersion]]]
    && [[headers objectForKey:HTTP_HEADER_AUTHORIZATION] isEqualToString:[NSString stringWithFormat:@"Bearer %@", self.oAuthToken]]
    && [[headers objectForKey:@"x-vf-trace-subject-id"] isEqualToString:[VDFDeviceUtility deviceUniqueIdentifier]]
    && (mcc == nil || [[headers objectForKey:@"x-vf-trace-subject-region"] isEqualToString:mcc])
    && [[headers objectForKey:@"x-vf-trace-source"] isEqualToString:[NSString stringWithFormat:@"iOS-%@-%@", self.appId, self.backendId]];
    

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
            if([self checkStandardRequiredHeaders:request]) {
                // check if-none-match header
                NSDictionary *headers = [request allHTTPHeaderFields];
                return [[headers objectForKey:HTTP_HEADER_IF_NONE_MATCH] isEqualToString:self.etag];
            }
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

- (OHHTTPStubsResponseBlock)responseEmpty200 { return [self responseEmptyWithCode:200]; }
- (OHHTTPStubsResponseBlock)responseEmpty404 { return [self responseEmptyWithCode:404]; }
- (OHHTTPStubsResponseBlock)responseEmpty500 { return [self responseEmptyWithCode:500]; }
- (OHHTTPStubsResponseBlock)responseEmpty400 { return [self responseEmptyWithCode:400]; }
- (OHHTTPStubsResponseBlock)responseEmpty401 { return [self responseEmptyWithCode:401]; }
- (OHHTTPStubsResponseBlock)responseEmpty403 { return [self responseEmptyWithCode:403]; }
- (OHHTTPStubsResponseBlock)responseEmpty409 { return [self responseEmptyWithCode:409]; }


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


- (OHHTTPStubsResponseBlock)responseResolve302NotFinished {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:302
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON,
                                                       HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@?backendId=%@",
                                                                              self.sessionToken, self.backendId],
                                                       HTTP_HEADER_RETRY_AFTER: @5000 }];
    };
}

- (OHHTTPStubsResponseBlock)responseResolve302SmsRequired {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:302
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON,
                                                       HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@/pins?backendId=%@",
                                                                              self.sessionToken, self.backendId],
                                                       HTTP_HEADER_RETRY_AFTER: @5000 }];
    };
}


- (OHHTTPStubsResponseBlock)responseCheckStatus302NotFinished {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:302
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON,
                                                       HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@?backendId=%@",
                                                                              self.sessionToken, self.backendId],
                                                       HTTP_HEADER_RETRY_AFTER: @5000,
                                                       HTTP_HEADER_ETAG: self.etag,
                                                       @"Cache-Control": @"must-revalidate"}];
    };
}

- (OHHTTPStubsResponseBlock)responseCheckStatus302SmsRequired {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil
                                          statusCode:302
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON,
                                                       HTTP_HEADER_LOCATION: [NSString stringWithFormat:@"/seamless-id/users/tokens/%@/pins?backendId=%@",
                                                                              self.sessionToken, self.backendId],
                                                       HTTP_HEADER_RETRY_AFTER: @5000,
                                                       HTTP_HEADER_ETAG: self.etag,
                                                       @"Cache-Control": @"must-revalidate"}];
    };
}

- (OHHTTPStubsResponseBlock)responseCheckStatus200 {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [[NSString stringWithFormat:@"{ \"acr\": \"%@\", \"expiresIn\": 60000, \"tokenId\": \"%@\" }",
                  self.acr, self.sessionToken] dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:201
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON,
                                                       HTTP_HEADER_ETAG: self.etag}];
    };
}


- (OHHTTPStubsResponseBlock)responseValidatePin200 {
    return ^OHHTTPStubsResponse*(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:
                [[NSString stringWithFormat:@"{ \"acr\": \"%@\", \"expiresIn\": 60000, \"tokenId\": \"%@\" }",
                  self.acr, self.sessionToken] dataUsingEncoding:NSUTF8StringEncoding]
                                          statusCode:201
                                             headers:@{HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON}];
    };
}



#pragma mark -
#pragma mark - stubs


- (id<OHHTTPStubsDescriptor>)stubRequest:(OHHTTPStubsTestBlock)requestFilter
                            withResponsesList:(NSArray*)responses {
    __weak __block id<OHHTTPStubsDescriptor> stub;
    
    // creating requests in reverse direction
    __block NSMutableArray *blocksArray = [NSMutableArray arrayWithCapacity:[responses count]];
    NSEnumerator *enumerator = [responses reverseObjectEnumerator];
    for (id element in enumerator) {
        [blocksArray addObject:element];
    }
    
    stub = [OHHTTPStubs stubRequestsPassingTest:requestFilter
                               withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
                                   OHHTTPStubsResponseBlock responseBlock = [[blocksArray lastObject] copy];
                                   
                                   if([blocksArray count] > 1) {
                                       // we have more then one waiting responses so we need to move next response:
                                       [blocksArray removeLastObject];
                                   }
                                   
                                   return responseBlock(request);
                               }];
    return stub;
}


@end

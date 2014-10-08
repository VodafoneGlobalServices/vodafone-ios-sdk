//
//  VDFUserResolveRequestFactory.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveRequestFactory.h"
#import "VDFUserResolveRequestState.h"
#import "VDFUserResolveResponseParser.h"
#import "VDFCacheObject.h"
#import "VDFHttpConnector.h"
#import "VDFUserResolveOptions.h"
#import "VDFEnums.h"
#import "VDFStringHelper.h"
#import "VDFErrorUtility.h"
#import "VDFBaseConfiguration.h"
#import "VDFUserResolveRequestBuilder.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFSettings.h"
#import "VDFDIContainer.h"
#import "VDFConsts.h"
#import "VDFUserResolveOptions+Internal.h"

static NSString * const DESCRIPTION_FORMAT = @"VDFUserResolveRequestFactory:\n\t initialURL:%@\n\t retryURL:%@";

@interface VDFUserResolveRequestFactory ()
@property (nonatomic, strong) VDFUserResolveRequestBuilder *builder;

- (NSString*)createInitialRequestUrlDirectlyToAPIX:(BOOL)directToAPIX;
- (NSString*)createRetryRequestUrl;
- (NSData*)postBody;
@end

@implementation VDFUserResolveRequestFactory

- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder {
    self = [super init];
    if(self) {
        self.builder = builder;
    }
    return self;
}

- (NSString*)description {
    BOOL directToAPIX = self.builder.requestOptions.market != nil && self.builder.requestOptions.msisdn != nil;
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self createInitialRequestUrlDirectlyToAPIX:directToAPIX], [self createRetryRequestUrl]];
}

- (NSString*)createInitialRequestUrlDirectlyToAPIX:(BOOL)directToAPIX {
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    NSString * requestUrl = directToAPIX ? configuration.apixHost : configuration.hapHost;
    requestUrl = [requestUrl stringByAppendingString:
                  [configuration.serviceBasePath stringByAppendingString:
                   [NSString stringWithFormat:SERVICE_URL_PATH_SCHEME_RESOLVE, configuration.backendAppKey]]];
    return requestUrl;
}

- (NSString*)createRetryRequestUrl {
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    return [configuration.apixHost stringByAppendingString:
            [configuration.serviceBasePath stringByAppendingString:
             [NSString stringWithFormat:SERVICE_URL_PATH_SCHEME_CHECK_RESOLVE_STATUS,
              self.builder.sessionToken, self.builder.backendAppKey]]];
}

- (NSData*)postBody {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    
    if(self.builder.requestOptions.smsValidation) {
        [jsonObject setObject:@"true" forKey:@"smsValidation"];
    }
    else {
        [jsonObject setObject:@"false" forKey:@"smsValidation"];
    }
    
    if(self.builder.requestOptions.market != nil) {
        [jsonObject setObject:self.builder.requestOptions.market forKey:@"market"];
    }
    
    if(self.builder.requestOptions.msisdn != nil) {
        [jsonObject setObject:self.builder.requestOptions.msisdn forKey:@"msisdn"];
    }
    
    NSData *result = nil;
    @try {
        result = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
    }
    @catch (NSException *exception) {
        result = [NSData data];
    }
    
    return result;
}

- (VDFHttpConnector*)createRetryHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = HTTPMethodGET;
    httpRequest.url = [self createRetryRequestUrl];
    httpRequest.allowRedirects = NO;
    
    NSString *authorizationHeader = [NSString stringWithFormat:@"%@ %@", self.builder.oAuthToken.tokenType, self.builder.oAuthToken.accessToken];
    httpRequest.requestHeaders = @{HTTP_HEADER_AUTHORIZATION: authorizationHeader,
                                   HTTP_HEADER_IF_NONE_MATCH: self.builder.eTag};
    
    return httpRequest;
}

#pragma mark -
#pragma mark VDFRequestFactory implementation

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = HTTPMethodPOST;
    httpRequest.postBody = [self postBody];
    httpRequest.allowRedirects = NO;
    
    BOOL directToAPIX = self.builder.requestOptions.market != nil && self.builder.requestOptions.msisdn != nil;
    httpRequest.url = [self createInitialRequestUrlDirectlyToAPIX:directToAPIX];
    
    if(!directToAPIX) {
//      httpRequest.isGSMConnectionRequired = YES; // TODO !!! uncomment this // commented only for test purposes
    }
    
    NSString *authorizationHeader = [NSString stringWithFormat:@"%@ %@", self.builder.oAuthToken.tokenType, self.builder.oAuthToken.accessToken];
    httpRequest.requestHeaders = @{HTTP_HEADER_AUTHORIZATION: authorizationHeader,
                                   HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON};
    
    
    return httpRequest;
}

- (VDFCacheObject*)createCacheObject {
    return nil; // this is not cachable
}

- (id<VDFResponseParser>)createResponseParser {
    return [[VDFUserResolveResponseParser alloc] init];
}

- (id<VDFRequestState>)createRequestState {
    return [[VDFUserResolveRequestState alloc] initWithBuilder:self.builder];
}

- (id<VDFObserversContainer>)createObserversContainer {
    id<VDFObserversContainer> observersContainer = [super createObserversContainer];
    [observersContainer setObserversNotifySelector:@selector(didReceivedUserDetails:withError:)];
    return observersContainer;
}

@end

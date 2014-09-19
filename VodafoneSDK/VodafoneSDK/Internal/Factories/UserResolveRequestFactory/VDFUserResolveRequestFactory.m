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

@interface VDFUserResolveRequestFactory ()
@property (nonatomic, strong) VDFUserResolveRequestBuilder *builder;

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
    
    NSString * requestUrl = [configuration.apixBaseUrl stringByAppendingString:self.builder.retryUrlEndpointQuery];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = HTTPMethodGET;
    httpRequest.url = requestUrl;
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
    
    
    NSString * requestUrl = nil;
    if(self.builder.requestOptions.market != nil && self.builder.requestOptions.msisdn != nil) {
        // it goes directly throught APIX
        requestUrl = [configuration.apixBaseUrl stringByAppendingString:self.builder.initialUrlEndpointQuery];
    }
    else {
        requestUrl = [configuration.hapBaseUrl stringByAppendingString:self.builder.initialUrlEndpointQuery];
//      httpRequest.isGSMConnectionRequired = YES; // TODO !!! uncomment this // commented only for test purposes
    }
    
    httpRequest.url = requestUrl;
    
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

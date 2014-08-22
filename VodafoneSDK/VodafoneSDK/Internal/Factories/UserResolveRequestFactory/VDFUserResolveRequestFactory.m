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

static NSString * const JSONPayloadBodyFormat = @"{ \"SMSValidation\" : %@ }";

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
    NSString *validateWithSmsString = nil;
    if(self.builder.requestOptions.validateWithSms) {
        validateWithSmsString = @"true";
    }
    else {
        validateWithSmsString = @"false";
    }
    return [[NSString stringWithFormat:JSONPayloadBodyFormat, validateWithSmsString] dataUsingEncoding:NSUTF8StringEncoding];
}

- (VDFHttpConnector*)createRetryHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    NSString * requestUrl = [self.builder.configuration.apixBaseUrl stringByAppendingString:self.builder.retryUrlEndpointQuery];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = self.builder.configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = HTTPMethodGET;
    httpRequest.url = requestUrl;
    
    NSString *authorizationHeader = [NSString stringWithFormat:@"%@ %@", self.builder.oAuthToken.tokenType, self.builder.oAuthToken.accessToken];
    httpRequest.requestHeaders = @{@"Authorization": authorizationHeader, @"User-Agent": [VDFSettings sdkVersion], @"Application-ID": self.builder.applicationId,
                                   @"ETag": self.builder.eTag};
    
    return httpRequest;
}

#pragma mark -
#pragma mark VDFRequestFactory implementation

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    NSString * requestUrl = [self.builder.configuration.hapBaseUrl stringByAppendingString:self.builder.initialUrlEndpointQuery];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = self.builder.configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = HTTPMethodPOST;
    httpRequest.postBody = [self postBody];
    httpRequest.url = requestUrl;
    
    NSString *authorizationHeader = [NSString stringWithFormat:@"%@ %@", self.builder.oAuthToken.tokenType, self.builder.oAuthToken.accessToken];
    httpRequest.requestHeaders = @{@"Authorization": authorizationHeader, @"User-Agent": [VDFSettings sdkVersion], @"Application-ID": self.builder.applicationId};
    
//    httpRequest.isGSMConnectionRequired = YES; // TODO !!! uncomment this // commented only for test purposes
    
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

//
//  VDFOAuthTokenRequestFactory.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenRequestFactory.h"
#import "VDFOAuthTokenRequestBuilder.h"
#import "VDFHttpConnector.h"
#import "VDFStringHelper.h"
#import "VDFCacheObject.h"
#import "VDFOAuthTokenResponseParser.h"
#import "VDFOAuthTokenRequestState.h"
#import "VDFBaseConfiguration.h"
#import "VDFOAuthTokenRequestOptions.h"
#import "VDFDIContainer.h"
#import "VDFConsts.h"

static NSString * const POST_BODY_FORMAT = @"grant_type=client_credentials&client_id=%@&client_secret=%@"; // TODO move grant type to configuration class
static NSString * const POST_BODY_SCOPE_PARAMETER_FORMAT = @"&scope=%@";

@interface VDFOAuthTokenRequestFactory ()
@property (nonatomic, strong) VDFOAuthTokenRequestBuilder *builder;

- (NSData*)postBody;
@end

@implementation VDFOAuthTokenRequestFactory

- (instancetype)initWithBuilder:(VDFOAuthTokenRequestBuilder*)builder {
    self = [super init];
    if(self) {
        self.builder = builder;
    }
    return self;
}

- (NSData*)postBody {
    
    // parameters encoding:
    NSString *encodedClientID = [VDFStringHelper urlEncode:self.builder.requestOptions.clientId];
    NSString *encodedClientSecret = [VDFStringHelper urlEncode:self.builder.requestOptions.clientSecret];

    // formating scopes:
    NSMutableString *bodyString = [NSMutableString stringWithFormat:POST_BODY_FORMAT, encodedClientID, encodedClientSecret];
    if(self.builder.requestOptions.scopes != nil)
    {
        for (NSString *scope in self.builder.requestOptions.scopes) {
            [bodyString appendFormat:POST_BODY_SCOPE_PARAMETER_FORMAT, [VDFStringHelper urlEncode:scope]];
        }
    }
    
    return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark VDFRequestFactory implementation

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
//    NSString * requestUrl = [configuration.apixBaseUrl stringByAppendingString:self.builder.urlEndpointQuery];
//    NSString * requestUrl = [@"https://apisit.developer.vodafone.com" stringByAppendingString:self.builder.urlEndpointQuery];
    NSString * requestUrl = [@"https://mr-4549932930.eu-de1.plex.vodafone.com" stringByAppendingString:self.builder.urlEndpointQuery];
    
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = self.builder.httpRequestMethodType;
    httpRequest.postBody = [self postBody];
    httpRequest.url = requestUrl;
    httpRequest.requestHeaders = @{ HTTP_HEADER_ACCEPT : HTTP_VALUE_CONTENT_TYPE_JSON,
                                    HTTP_HEADER_CONTENT_TYPE : HTTP_VALUE_CONTENT_TYPE_WWW_FORM };
    
    return httpRequest;
}

- (VDFCacheObject*)createCacheObject {
    NSString *stringToHash = [NSString stringWithFormat:@"%@%ul%@", self.builder.urlEndpointQuery, self.builder.httpRequestMethodType, [VDFStringHelper md5FromData:[self postBody]]];
    NSString *md5Hash = [VDFStringHelper md5FromString:stringToHash];
    
    id<VDFRequestState> currentState = [self.builder requestState];
    
    return [[VDFCacheObject alloc] initWithValue:nil forKey:md5Hash withExpirationDate:[currentState lastResponseExpirationDate]];
}

- (id<VDFResponseParser>)createResponseParser {
    return [[VDFOAuthTokenResponseParser alloc] init];
}

- (id<VDFRequestState>)createRequestState {
    return [[VDFOAuthTokenRequestState alloc] init];
}

- (id<VDFObserversContainer>)createObserversContainer {
    id<VDFObserversContainer> observersContainer = [super createObserversContainer];
    [observersContainer setObserversNotifySelector:@selector(didReceivedOAuthToken:withError:)];
    return observersContainer;
}

@end

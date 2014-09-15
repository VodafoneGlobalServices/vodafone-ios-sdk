//
//  VDFSmsSendPinRequestFactory.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsSendPinRequestFactory.h"
#import "VDFSmsSendPinRequestBuilder.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnector.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFSettings+Internal.h"
#import "VDFSettings.h"
#import "VDFSmsSendPinRequestState.h"
#import "VDFSmsSendPinResponseParser.h"
#import "VDFDIContainer.h"
#import "VDFConsts.h"

@interface VDFSmsSendPinRequestFactory ()
@property (nonatomic, strong) VDFSmsSendPinRequestBuilder *builder;
@end

@implementation VDFSmsSendPinRequestFactory

- (instancetype)initWithBuilder:(VDFSmsSendPinRequestBuilder*)builder {
    self = [super init];
    if(self) {
        self.builder = builder;
    }
    return self;
}

#pragma mark -
#pragma mark VDFRequestFactory implementation

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    NSString * requestUrl = [configuration.apixBaseUrl stringByAppendingString:self.builder.urlEndpointQuery];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = self.builder.httpRequestMethodType;
    httpRequest.url = requestUrl;
    httpRequest.isGSMConnectionRequired = NO;
    
    NSString *authorizationHeader = [NSString stringWithFormat:@"%@ %@", self.builder.oAuthToken.tokenType, self.builder.oAuthToken.accessToken];
    httpRequest.requestHeaders = @{HTTP_HEADER_AUTHORIZATION: authorizationHeader};
    
    return httpRequest;
}

- (VDFCacheObject*)createCacheObject {
    return nil; // it is not cached
}

- (id<VDFResponseParser>)createResponseParser {
    return [[VDFSmsSendPinResponseParser alloc] init];
}

- (id<VDFRequestState>)createRequestState {
    return [[VDFSmsSendPinRequestState alloc] init];
}

- (id<VDFObserversContainer>)createObserversContainer {
    id<VDFObserversContainer> observersContainer = [super createObserversContainer];
    [observersContainer setObserversNotifySelector:@selector(didSMSPinRequested:withError:)];
    return observersContainer;
}


@end

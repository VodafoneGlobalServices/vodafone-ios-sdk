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
#import "VDFSmsSendPinObserversContainer.h"

static NSString * const DESCRIPTION_FORMAT = @"VDFSmsSendPinRequestFactory:\n\t URL:%@\n\t";

@interface VDFSmsSendPinRequestFactory ()
@property (nonatomic, strong) VDFSmsSendPinRequestBuilder *builder;

- (NSString*)createRequestURL;
@end

@implementation VDFSmsSendPinRequestFactory

- (instancetype)initWithBuilder:(VDFSmsSendPinRequestBuilder*)builder {
    self = [super init];
    if(self) {
        self.builder = builder;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self createRequestURL]];
}

- (NSString*)createRequestURL {
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    return [configuration.apixHost stringByAppendingString:
            [configuration.serviceBasePath stringByAppendingString:
             [NSString stringWithFormat:SERVICE_URL_PATH_SCHEME_SEND_PIN,
              self.builder.sessionToken, self.builder.backendAppKey]]];
}

#pragma mark -
#pragma mark VDFRequestFactory implementation

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = HTTPMethodGET;
    httpRequest.url = [self createRequestURL];
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
    id<VDFObserversContainer> observersContainer = [[VDFSmsSendPinObserversContainer alloc] init];
    [observersContainer setObserversNotifySelector:@selector(didSMSPinRequested:withError:)];
    return observersContainer;
}


@end

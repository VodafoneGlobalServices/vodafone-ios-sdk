//
//  VDFSmsValidationRequestFactory.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationRequestFactory.h"
#import "VDFSmsValidationRequestBuilder.h"
#import "VDFStringHelper.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnector.h"
#import "VDFCacheObject.h"
#import "VDFSmsValidationRequestState.h"
#import "VDFSmsValidationResponseParser.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFSettings.h"
#import "VDFSettings+Internal.h"
#import "VDFDIContainer.h"
#import "VDFConsts.h"

static NSString * const JSONPayloadBodyFormat = @"{ \"code\" : \"%@\" }";
static NSString * const DESCRIPTION_FORMAT = @"VDFSmsValidationRequestFactory:\n\t URL:%@\n\t";

@interface VDFSmsValidationRequestFactory ()
@property (nonatomic, strong) VDFSmsValidationRequestBuilder *builder;

- (NSString*)createRequestURL;
- (NSData*)postBody;
@end

@implementation VDFSmsValidationRequestFactory

- (instancetype)initWithBuilder:(VDFSmsValidationRequestBuilder*)builder {
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
             [NSString stringWithFormat:SERVICE_URL_PATH_SCHEME_VALIDATE_PIN,
              self.builder.sessionToken, configuration.backendAppKey]]];
}

- (NSData*)postBody {
    // faster and sipler will be to format the string
    return [[NSString stringWithFormat:JSONPayloadBodyFormat, [VDFStringHelper urlEncode:self.builder.smsCode]] dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark VDFRequestFactory implementation

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = HTTPMethodPOST;
    httpRequest.postBody = [self postBody];
    httpRequest.url = [self createRequestURL];
    httpRequest.isGSMConnectionRequired = NO;
    
    NSString *authorizationHeader = [NSString stringWithFormat:@"%@ %@", self.builder.oAuthToken.tokenType, self.builder.oAuthToken.accessToken];
    httpRequest.requestHeaders = @{HTTP_HEADER_AUTHORIZATION: authorizationHeader,
                                   HTTP_HEADER_CONTENT_TYPE: HTTP_VALUE_CONTENT_TYPE_JSON};
    
    return httpRequest;
}

- (VDFCacheObject*)createCacheObject {
    return nil; // it is not cached
}

- (id<VDFResponseParser>)createResponseParser {
    return [[VDFSmsValidationResponseParser alloc] initWithRequestSmsCode:self.builder.smsCode];
}

- (id<VDFRequestState>)createRequestState {
    return [[VDFSmsValidationRequestState alloc] init];
}

- (id<VDFObserversContainer>)createObserversContainer {
    id<VDFObserversContainer> observersContainer = [super createObserversContainer];
    [observersContainer setObserversNotifySelector:@selector(didValidatedSMSToken:withError:)];
    return observersContainer;
}

@end

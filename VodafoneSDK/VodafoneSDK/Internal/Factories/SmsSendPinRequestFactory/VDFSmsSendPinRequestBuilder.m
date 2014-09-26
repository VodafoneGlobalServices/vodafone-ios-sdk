//
//  VDFSmsSendPinRequestBuilder.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsSendPinRequestBuilder.h"
#import "VDFSmsSendPinRequestFactory.h"
#import "VDFOAuthTokenRequestOptions.h"
#import "VDFOAuthTokenRequestBuilder.h"
#import "VDFBaseConfiguration.h"
#import "VDFError.h"
#import "VDFDIContainer.h"
#import "VDFConsts.h"

static NSString * const DESCRIPTION_FORMAT = @"VDFSmsSendPinRequestBuilder:\n\t urlEndpointMethod:%@ \n\t httpMethod:%@ \n\t clientAppKey:%@ \n\t backendAppKey:%@ \n\t sessionToken:%@ ";

@interface VDFSmsSendPinRequestBuilder ()
@property (nonatomic, strong) VDFSmsSendPinRequestFactory *internalFactory;
@end


@implementation VDFSmsSendPinRequestBuilder

- (instancetype)initWithSessionToken:(NSString*)sessionToken diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super initWithDIContainer:diContainer];
    if(self) {
        self.internalFactory = [[VDFSmsSendPinRequestFactory alloc] initWithBuilder:self];
        
        VDFBaseConfiguration *configuration = [diContainer resolveForClass:[VDFBaseConfiguration class]];
        _urlEndpointQuery = [NSString stringWithFormat:SERVICE_URL_SCHEME_SEND_PIN, sessionToken, configuration.backendAppKey];
        _httpRequestMethodType = HTTPMethodGET;
        self.sessionToken = sessionToken;
        self.oAuthToken = nil;
        
        if(delegate != nil) {
            [[self observersContainer] registerObserver:delegate];
        }
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self urlEndpointQuery], ([self httpRequestMethodType] == HTTPMethodGET) ? @"GET":@"POST", self.clientAppKey, self.backendAppKey, self.sessionToken];
}

#pragma mark -
#pragma mark VDFRequestFactoryBuilder Implementation

- (id<VDFRequestFactory>)factory {
    return self.internalFactory;
}

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    if(builder == nil || ![builder isKindOfClass:[VDFSmsSendPinRequestBuilder class]]) {
        return NO;
    }
    
    VDFSmsSendPinRequestBuilder * smsValidationBuilder = (VDFSmsSendPinRequestBuilder*)builder;
    if(![self.clientAppKey isEqualToString:smsValidationBuilder.clientAppKey]) {
        return NO;
    }
    if(![self.clientAppSecret isEqualToString:smsValidationBuilder.clientAppSecret]) {
        return NO;
    }
    if(![self.backendAppKey isEqualToString:smsValidationBuilder.backendAppKey]) {
        return NO;
    }
    
    return [self.sessionToken isEqualToString:smsValidationBuilder.sessionToken];
}

@end

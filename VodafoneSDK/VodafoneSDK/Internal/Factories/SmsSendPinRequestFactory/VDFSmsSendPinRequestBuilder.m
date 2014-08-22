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

static NSString * const URLEndpointQuery = @"/he/users/tokens/sendPIN/";
static NSString * const DESCRIPTION_FORMAT = @"VDFSmsSendPinRequestBuilder:\n\t urlEndpointMethod:%@ \n\t httpMethod:%@ \n\t applicationId:%@ \n\t sessionToke:%@ ";

@interface VDFSmsSendPinRequestBuilder ()
@property (nonatomic, strong) VDFSmsSendPinRequestFactory *internalFactory;
@end


@implementation VDFSmsSendPinRequestBuilder

- (instancetype)initWithApplicationId:(NSString*)applicationId sessionToken:(NSString*)sessionToken withConfiguration:(VDFBaseConfiguration*)configuration delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super initWithApplicationId:applicationId configuration:configuration];
    if(self) {
        self.internalFactory = [[VDFSmsSendPinRequestFactory alloc] initWithBuilder:self];
        
        _urlEndpointQuery = [URLEndpointQuery stringByAppendingString:sessionToken];
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
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self urlEndpointQuery], ([self httpRequestMethodType] == HTTPMethodGET) ? @"GET":@"POST", self.applicationId, self.sessionToken];
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
    if(![self.applicationId isEqualToString:smsValidationBuilder.applicationId]) {
        return NO;
    }
    
    return [self.sessionToken isEqualToString:smsValidationBuilder.sessionToken];
}

#pragma mark -
#pragma mark VDFOAuthTokenRequestDelegate implementation

-(void)didReceivedOAuthToken:(VDFOAuthTokenResponse*)oAuthToken withError:(NSError*)error {
    if(oAuthToken != nil || error == nil) {
        // everything looks fine:
        self.oAuthToken = oAuthToken;
    }
    // error handling is done in decorator class so here we only expects to store valid token
}

@end

//
//  VDFUserResolveRequestFactoryBuilder.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveRequestBuilder.h"
#import "VDFUserResolveRequestFactory.h"
#import "VDFBaseConfiguration.h"
#import "VDFUserResolveOptions.h"
#import "VDFOAuthTokenRequestBuilder.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFOAuthTokenRequestOptions.h"
#import "VDFError.h"

static NSString * const URLEndpointQuery = @"/users/resolve";
static NSString * const DESCRIPTION_FORMAT = @"VDFUserResolveRequestFactoryBuilder:\n\t urlEndpointMethod:%@ \n\t httpMethod:%@ \n\t applicationId:%@ \n\t requestOptions:%@ ";

@interface VDFUserResolveRequestBuilder ()
@property (nonatomic, strong) VDFUserResolveRequestFactory *internalFactory;
@property (nonatomic, assign) id restorePointObject;
@property (nonatomic, assign) SEL restorePointSelector;
@end

@implementation VDFUserResolveRequestBuilder

- (instancetype)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options withConfiguration:(VDFBaseConfiguration*)configuration delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super initWithApplicationId:applicationId configuration:configuration];
    if(self) {
        self.internalFactory = [[VDFUserResolveRequestFactory alloc] initWithBuilder:self];
        
        _urlEndpointQuery = URLEndpointQuery;
        _httpRequestMethodType = HTTPMethodPOST;
        
        self.requestOptions = [options copy]; // we need to copy this options because if the session token will change we need to update it
        self.oAuthToken = nil;
        
        if(delegate != nil) {
            [[self observersContainer] registerObserver:delegate];
        }
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self urlEndpointQuery], ([self httpRequestMethodType] == HTTPMethodGET) ? @"GET":@"POST", self.applicationId, self.requestOptions];
}

#pragma mark -
#pragma mark VDFRequestFactoryBuilder Implementation

- (id<VDFRequestFactory>)factory {
    return self.internalFactory;
}

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    if(builder == nil || ![builder isKindOfClass:[VDFUserResolveRequestBuilder class]]) {
        return NO;
    }
    
    VDFUserResolveRequestBuilder *userResolveBuilder = (VDFUserResolveRequestBuilder*)builder;
    if(![self.applicationId isEqualToString:userResolveBuilder.applicationId]) {
        return NO;
    }
    
    return [self.requestOptions isEqualToOptions:userResolveBuilder.requestOptions];
}


#pragma mark Dependant methods implementation
- (id<VDFRequestBuilder>)dependentRequestBuilder {
    if(self.oAuthToken == nil) {
        VDFOAuthTokenRequestOptions *oAuthOptions = [[VDFOAuthTokenRequestOptions alloc] init];
        oAuthOptions.clientId = self.configuration.oAuthTokenClientId;
        oAuthOptions.clientSecret = self.configuration.oAuthTokenClientSecret;
        oAuthOptions.scopes = @[self.configuration.oAuthTokenScope];
        
        return [[VDFOAuthTokenRequestBuilder alloc] initWithApplicationId:self.applicationId
                                                              withOptions:oAuthOptions
                                                        withConfiguration:self.configuration
                                                                 delegate:self];
    }
    return nil;
}

- (void)setResumeTarget:(id)object selector:(SEL)selector {
    self.restorePointObject = object;
    self.restorePointSelector = selector;
}

#pragma mark -
#pragma mark VDFOAuthTokenRequestDelegate implementation

-(void)didReceivedOAuthToken:(VDFOAuthTokenResponse*)oAuthToken withError:(NSError*)error {
    if(error != nil || oAuthToken == nil) {
        if(error == nil) {
            error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorServerCommunication userInfo:nil];
        }
        // there is some error, forward this:
        [[self observersContainer] notifyAllObserversWith:nil error:error];
    }
    else {
        // everything looks fine:
        self.oAuthToken = oAuthToken;
        
        // lets move one with this request:
        [self.restorePointObject performSelector:self.restorePointSelector withObject:self];
    }
}

@end

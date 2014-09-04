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
#import "VDFHttpConnector.h"
#import "VDFConfigurationManager.h"
#import "VDFDIContainer.h"

static NSString * const InitialURLEndpointQuery = @"/users/resolve";
static NSString * const RetryURLEndpointQuery = @"/users/tokens/checkstatus/%@";
static NSString * const DESCRIPTION_FORMAT = @"VDFUserResolveRequestFactoryBuilder:\n\t initialUrlEndpointQuery:%@ \n\t retryUrlEndpointQuery:%@ \n\t httpMethod:%@ \n\t applicationId:%@ \n\t requestOptions:%@ ";

@interface VDFUserResolveRequestBuilder ()
@property (nonatomic, strong) VDFUserResolveRequestFactory *internalFactory;
@end

@implementation VDFUserResolveRequestBuilder

@synthesize sessionToken = _sessionToken;

- (instancetype)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super initWithApplicationId:applicationId diContainer:diContainer];
    if(self) {
        self.internalFactory = [[VDFUserResolveRequestFactory alloc] initWithBuilder:self];
        
        _initialUrlEndpointQuery = InitialURLEndpointQuery;
        _httpRequestMethodType = HTTPMethodPOST;
        
        self.requestOptions = [options copy]; // we need to copy this options because if the session token will change we need to update it
        self.oAuthToken = nil;
        
        if(delegate != nil) {
            [[self observersContainer] registerObserver:delegate];
        }
    }
    return self;
}

- (NSString*)sessionToken {
    return _sessionToken;
}

- (void)setSessionToken:(NSString*)sessionToken {
    _sessionToken = sessionToken;
    _retryUrlEndpointQuery = [NSString stringWithFormat:RetryURLEndpointQuery, sessionToken];
}

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self initialUrlEndpointQuery], [self retryUrlEndpointQuery], ([self httpRequestMethodType] == HTTPMethodGET) ? @"GET":@"POST", self.applicationId, self.requestOptions];
}

#pragma mark -
#pragma mark VDFRequestFactoryBuilder Implementation

- (VDFHttpConnector*)createCurrentHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    // here we need to override first request because if we have eTag then we need to use APIX server for updates
    if(self.eTag != nil) {
        return [self.internalFactory createRetryHttpConnectorWithDelegate:delegate];
    }
    else {
        // on creation of first connection object we need to perform update of configuration
        VDFConfigurationManager *configurationManager = [self.diContainer resolveForClass:[VDFConfigurationManager class]];
        [configurationManager checkForUpdate];
        
        return [super createCurrentHttpConnectorWithDelegate:delegate];
    }
}

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

@end

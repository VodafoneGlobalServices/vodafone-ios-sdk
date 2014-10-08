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
#import "VDFConsts.h"

static NSString * const DESCRIPTION_FORMAT = @"VDFUserResolveRequestFactoryBuilder:\n\t %@\n\t internalFactory:%@ \n\t requestOptions:%@ ";

@interface VDFUserResolveRequestBuilder ()
@property (nonatomic, strong) VDFUserResolveRequestFactory *internalFactory;
@end

@implementation VDFUserResolveRequestBuilder

@synthesize sessionToken = _sessionToken;

- (instancetype)initWithOptions:(VDFUserResolveOptions*)options diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super initWithDIContainer:diContainer];
    if(self) {
        self.internalFactory = [[VDFUserResolveRequestFactory alloc] initWithBuilder:self];
        self.requestOptions = options;
        self.oAuthToken = nil;
        
        if(delegate != nil) {
            [[self observersContainer] registerObserver:delegate];
        }
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [super description], self.internalFactory, self.requestOptions];
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
    if(![self.clientAppKey isEqualToString:userResolveBuilder.clientAppKey]) {
        return NO;
    }
    if(![self.clientAppSecret isEqualToString:userResolveBuilder.clientAppSecret]) {
        return NO;
    }
    if(![self.backendAppKey isEqualToString:userResolveBuilder.backendAppKey]) {
        return NO;
    }
    
    return [self.requestOptions isEqualToOptions:userResolveBuilder.requestOptions];
}

@end

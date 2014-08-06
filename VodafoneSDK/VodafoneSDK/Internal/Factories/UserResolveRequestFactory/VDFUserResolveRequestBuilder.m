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

static NSString * const URLEndpointQuery = @"/users/resolve";
static NSString * const DESCRIPTION_FORMAT = @"VDFUserResolveRequestFactoryBuilder:\n\t urlEndpointMethod:%@ \n\t httpMethod:%@ \n\t applicationId:%@ \n\t requestOptions:%@ ";

@interface VDFUserResolveRequestBuilder ()
@property (nonatomic, assign) id<VDFUsersServiceDelegate> delegate;
@end

@implementation VDFUserResolveRequestBuilder

- (instancetype)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options withConfiguration:(VDFBaseConfiguration*)configuration delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super initWithFactory:[[VDFUserResolveRequestFactory alloc] initWithBuilder:self] applicationId:applicationId configuration:configuration];
    if(self) {
        _urlEndpointQuery = URLEndpointQuery;
        _httpRequestMethodType = HTTPMethodPOST;
        
        self.requestOptions = [options copy]; // we need to copy this options because if the session token will change we need to update it
        self.delegate = delegate;
        
        [[self observersContainer] registerObserver:self.delegate];
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self urlEndpointQuery], ([self httpRequestMethodType] == HTTPMethodGET) ? @"GET":@"POST", self.applicationId, self.requestOptions];
}

#pragma mark -
#pragma mark VDFRequestFactoryBuilder Implementation

- (id)observer {
    return self.delegate;
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

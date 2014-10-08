//
//  VDFOAuthTokenRequestBuilder.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenRequestBuilder.h"
#import "VDFOAuthTokenRequestOptions.h"
#import "VDFOAuthTokenRequestFactory.h"
#import "VDFOAuthTokenRequestDelegate.h"
#import "VDFConsts.h"

static NSString * const DESCRIPTION_FORMAT = @"VDFOAuthTokenRequestBuilder:\n\t %@\n\t internalFactory:%@\n\t requestOptions:%@ ";

@interface VDFOAuthTokenRequestBuilder ()
@property (nonatomic, strong) VDFOAuthTokenRequestFactory *internalFactory;
@end

@implementation VDFOAuthTokenRequestBuilder

- (instancetype)initWithOptions:(VDFOAuthTokenRequestOptions*)options diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFOAuthTokenRequestDelegate>)delegate {
    self = [super initWithDIContainer:diContainer];
    if(self) {
        self.internalFactory = [[VDFOAuthTokenRequestFactory alloc] initWithBuilder:self];
        self.requestOptions = options;
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

- (id<VDFRequestFactory>)factory {
    return self.internalFactory;
}

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    if(builder == nil || ![builder isKindOfClass:[VDFOAuthTokenRequestBuilder class]]) {
        return NO;
    }
    
    VDFOAuthTokenRequestBuilder *tokenRequestBuilder = (VDFOAuthTokenRequestBuilder*)builder;
    if(![self.clientAppKey isEqualToString:tokenRequestBuilder.clientAppKey]) {
        return NO;
    }
    if(![self.clientAppSecret isEqualToString:tokenRequestBuilder.clientAppSecret]) {
        return NO;
    }
    if(![self.backendAppKey isEqualToString:tokenRequestBuilder.backendAppKey]) {
        return NO;
    }
    
    return [self.requestOptions isEqualToOptions:tokenRequestBuilder.requestOptions];
}

@end

//
//  VDFRequestBuilderWithOAuth.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 21/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBuilderWithOAuth.h"
#import "VDFOAuthTokenRequestOptions.h"
#import "VDFOAuthTokenRequestBuilder.h"
#import "VDFError.h"
#import "VDFRequestBaseBuilder.h"
#import "VDFBaseConfiguration.h"
#import "VDFDIContainer.h"

@interface VDFRequestBuilderWithOAuth ()
@property (nonatomic, strong) VDFRequestBaseBuilder *builder;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) id restorePointObject;
@property (nonatomic, assign) SEL restorePointSelector;
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;
@end

@implementation VDFRequestBuilderWithOAuth

- (instancetype)initWithBuilder:(VDFRequestBaseBuilder*)builder oAuthTokenSetSelector:(SEL)selector {
    self = [super init];
    if(self) {
        self.builder = builder;
        self.selector = selector;
        self.oAuthToken = nil;
    }
    return self;
}

- (NSString*)description {
    return [self.builder description];
}

#pragma mark -
#pragma mark VDFOAuthTokenRequestDelegate

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
        [self.builder performSelector:self.selector withObject:self.oAuthToken];
        
        // lets move one with this request:
        [self.restorePointObject performSelector:self.restorePointSelector withObject:self];
    }
}

#pragma mark -
#pragma mark VDFRequestBuilder

- (id<VDFRequestBuilder>)dependentRequestBuilder {
    id result = nil;
    
    if([self.builder respondsToSelector:@selector(dependentRequestBuilder)]) {
        result = [self.builder dependentRequestBuilder];
    }
    
    if(result == nil && self.oAuthToken == nil) {
        VDFBaseConfiguration *configuration = [self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]];
        
        // creating oauthtoken request
        VDFOAuthTokenRequestOptions *oAuthOptions = [[VDFOAuthTokenRequestOptions alloc] init];
        oAuthOptions.clientId = configuration.oAuthTokenClientId;
        oAuthOptions.clientSecret = configuration.oAuthTokenClientSecret;
        oAuthOptions.scopes = @[configuration.oAuthTokenScope];
        
        return [[VDFOAuthTokenRequestBuilder alloc] initWithOptions:oAuthOptions
                                                        diContainer:self.builder.diContainer
                                                           delegate:self];
    }
    
    return result;
}

- (void)setResumeTarget:(id)target selector:(SEL)selector {
    self.restorePointObject = target;
    self.restorePointSelector = selector;
}

#pragma mark -
#pragma mark VDFRequestBuilder implementation as proxy


- (id<VDFRequestFactory>)factory { return [self.builder factory]; }

- (id<VDFResponseParser>)responseParser { return [self.builder responseParser]; }

- (id<VDFRequestState>)requestState { return [self.builder requestState]; }

- (id<VDFObserversContainer>)observersContainer { return [self.builder observersContainer]; }

- (VDFHttpConnector*)createCurrentHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    return [self.builder createCurrentHttpConnectorWithDelegate:delegate];
}

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    if(builder != nil) {
        if([builder isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return [self.builder isEqualToFactoryBuilder:((VDFRequestBuilderWithOAuth*)builder).builder];
        }
        return [self.builder isEqualToFactoryBuilder:builder];
    }
    return NO;
}

@end

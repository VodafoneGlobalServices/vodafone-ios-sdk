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
#import "VDFOAuthTokenRequestState.h"
#import "VDFRequestStateWithOAuth.h"
#import "VDFCacheObject.h"
#import "VDFCacheManager.h"

@interface VDFRequestBuilderWithOAuth ()
@property (nonatomic, strong) VDFRequestBaseBuilder *activeBuilder; // currently used builder
@property (nonatomic, strong) VDFRequestStateWithOAuth *activeRequestState; // currently used request state object
@property (nonatomic, strong) VDFRequestBaseBuilder *initiallyDecoratedBuilder;
@property (nonatomic, strong) VDFRequestStateWithOAuth *initiallyDecoratedRequestState;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) id restorePointObject;
@property (nonatomic, assign) SEL restorePointSelector;
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;
@property (nonatomic, strong) VDFOAuthTokenRequestBuilder *oAuthRequestBuilder;
@end

@implementation VDFRequestBuilderWithOAuth

@synthesize oAuthRequestBuilder = _oAuthRequestBuilder;

- (instancetype)initWithBuilder:(VDFRequestBaseBuilder*)builder oAuthTokenSetSelector:(SEL)selector {
    self = [super init];
    if(self) {
        self.activeBuilder = builder;
        self.initiallyDecoratedBuilder = builder;
        self.selector = selector;
        self.oAuthToken = nil;
        self.oAuthRequestBuilder = nil;
        
        self.initiallyDecoratedRequestState = [[VDFRequestStateWithOAuth alloc] initWithRequestState:[builder requestState] andParentBuilder:self];
        self.activeRequestState = self.initiallyDecoratedRequestState;
    }
    return self;
}

- (NSString*)description {
    return [self.activeBuilder description];
}

- (VDFOAuthTokenRequestBuilder*)oAuthRequestBuilder {
    if(_oAuthRequestBuilder == nil) {
        VDFBaseConfiguration *configuration = [self.activeBuilder.diContainer resolveForClass:[VDFBaseConfiguration class]];
        
        // creating oauthtoken request
        VDFOAuthTokenRequestOptions *oAuthOptions = [[VDFOAuthTokenRequestOptions alloc] init];
        oAuthOptions.clientId = configuration.clientAppKey;
        oAuthOptions.clientSecret = configuration.clientAppSecret;
        oAuthOptions.scopes = @[configuration.oAuthTokenScope];
        
        _oAuthRequestBuilder = [[VDFOAuthTokenRequestBuilder alloc] initWithOptions:oAuthOptions
                                                                        diContainer:self.activeBuilder.diContainer
                                                                           delegate:self];
    }
    return _oAuthRequestBuilder;
}

- (void)setNeedRetryForOAuth:(BOOL)needOAuth {
    if(needOAuth) {
        // when we need o Auth then we change the currently decorates builder
        // because call is currenlty pending so we cannot use dependant functionality
        [((VDFOAuthTokenRequestState*)[self.oAuthRequestBuilder requestState]) setNeedRetryUntilFirstResponse:YES];
        self.restorePointObject = nil;
        self.activeBuilder = self.oAuthRequestBuilder;
        self.activeRequestState = nil;
        
        // we need to remove oAuthToken from cache because when we get APIX error with current oAuth token then we cannot use it for next usage
        [self updateOAuthTokenInCache:nil];
    }
    else {
        self.activeBuilder = self.initiallyDecoratedBuilder;
        self.activeRequestState = self.initiallyDecoratedRequestState;
    }
}

- (void)updateOAuthTokenInCache:(VDFOAuthTokenResponse*)oAuthTokenDetails {
    
    VDFCacheObject *cacheObject = [[self oAuthRequestBuilder].factory createCacheObject];
    if(cacheObject != nil) {
        cacheObject.cacheValue = (id<NSCoding>)oAuthTokenDetails;
        if(oAuthTokenDetails == nil) {
            cacheObject.expirationDate = [NSDate distantPast];
        }
        [[self.activeBuilder.diContainer resolveForClass:[VDFCacheManager class]] cacheObject:cacheObject];
    }
}

- (BOOL)isDecoratedBuilderKindOfClass:(Class)classType {
    return [self.activeBuilder isKindOfClass:classType];
}

#pragma mark -
#pragma mark VDFOAuthTokenRequestDelegate

-(void)didReceivedOAuthToken:(VDFOAuthTokenResponse*)oAuthToken withError:(NSError*)error {
    if(error != nil || oAuthToken == nil) {
        if(error == nil) {
            error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorServerCommunication userInfo:nil];
        }
        // there is some error with o auth token, forward this:
        [[self.initiallyDecoratedBuilder observersContainer] notifyAllObserversWith:nil error:error];
    }
    else {
        // everything looks fine:
        self.oAuthToken = oAuthToken;
        [self.initiallyDecoratedBuilder performSelector:self.selector withObject:self.oAuthToken];
        
        // lets move one with this request:
        if(self.restorePointObject != nil) {
            [self.restorePointObject performSelector:self.restorePointSelector withObject:self];
        }
        else {
            // if restore point is not set, then this response is for expired oAuthToken
            [self setNeedRetryForOAuth:NO];
            
            // and we need to store this token in cache because this go over retry request, but the best way to do this will be to handled in depend request
            [self updateOAuthTokenInCache:oAuthToken];
        }
    }
}

#pragma mark -
#pragma mark VDFRequestBuilder

- (id<VDFRequestBuilder>)dependentRequestBuilder {
    id result = nil;
    
    if([self.activeBuilder respondsToSelector:@selector(dependentRequestBuilder)]) {
        result = [self.activeBuilder dependentRequestBuilder];
    }
    
    if(result == nil && self.oAuthToken == nil) {
        return self.oAuthRequestBuilder;
    }
    
    return result;
}

- (void)setResumeTarget:(id)target selector:(SEL)selector {
    self.restorePointObject = target;
    self.restorePointSelector = selector;
}

#pragma mark -
#pragma mark VDFRequestBuilder implementation as proxy


- (id<VDFRequestFactory>)factory { return [self.activeBuilder factory]; }

- (id<VDFResponseParser>)responseParser { return [self.activeBuilder responseParser]; }

- (id<VDFRequestState>)requestState {
    if(self.activeRequestState != nil) {
        return self.activeRequestState;
    }
    return [self.activeBuilder requestState];
}

- (id<VDFObserversContainer>)observersContainer { return [self.activeBuilder observersContainer]; }

- (VDFHttpConnector*)createCurrentHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    return [self.activeBuilder createCurrentHttpConnectorWithDelegate:delegate];
}

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    if(builder != nil) {
        if([builder isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return [self.initiallyDecoratedBuilder isEqualToFactoryBuilder:((VDFRequestBuilderWithOAuth*)builder).initiallyDecoratedBuilder];
        }
        return [self.initiallyDecoratedBuilder isEqualToFactoryBuilder:builder];
    }
    return NO;
}

@end

//
//  VDFRequestStateOAuthAdapter.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 16/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestStateWithOAuth.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFError.h"
#import "VDFRequestBuilderWithOAuth.h"
#import "VDFLogUtility.h"
#import "VDFRequestState.h"

@interface VDFRequestStateWithOAuth ()
@property (nonatomic, weak) VDFRequestBuilderWithOAuth *parentBuilder;
@property (nonatomic, strong) id<VDFRequestState> internalRequestState;
@property (nonatomic, strong) NSError *apixError;
@end

@implementation VDFRequestStateWithOAuth

- (instancetype)initWithRequestState:(id<VDFRequestState>)requestState andParentBuilder:(VDFRequestBuilderWithOAuth*)builder {
    self = [super init];
    if(self) {
        self.parentBuilder = builder;
        self.internalRequestState = requestState;
        self.needRetryForOAuth = NO;
        self.apixError = nil;
    }
    return self;
}

#pragma mark - VDFRequestState Implementation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    self.needRetryForOAuth = NO;
    
    if(response != nil && response.data != nil && response.httpResponseCode == 403) {
        // need to check is this error code from apix
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:nil];
        
        if(jsonObject != nil && [jsonObject isKindOfClass:[NSDictionary class]]) {
            
            // is error code from APIX ?
            NSString *errorCode = [jsonObject objectForKey:@"id"];
            NSString *errorDescription = [jsonObject objectForKey:@"description"];
            if(errorCode != nil && errorDescription != nil) {
                BOOL isOAuthExpired = [errorCode isEqualToString:@"POL0002"] && [errorDescription isEqualToString:@"Privacy Verification Failed - Authorization"];
                
                if(isOAuthExpired) {
                    self.needRetryForOAuth = YES;
                    [self.parentBuilder setNeedRetryForOAuth:YES];
                    VDFLogD(@"!!!! OAUTH NEED RETRY !!!!!");
                }
                else if([errorCode isEqualToString:@"POL0001"] || [errorCode isEqualToString:@"POL0002"]) {
                    // there is some APIX error
                    self.apixError = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorAuthorizationFailed userInfo:nil];
                    // remove current o Auth token from cache:
                    [self.parentBuilder updateOAuthTokenInCache:nil];
                }
            }
        }
    }
    
    if(!self.needRetryForOAuth) {
        [self.internalRequestState updateWithHttpResponse:response];
    }
}

- (void)updateWithParsedResponse:(id)parsedResponse {
    if(!self.needRetryForOAuth) {
        [self.internalRequestState updateWithParsedResponse:parsedResponse];
    }
}

- (BOOL)isRetryNeeded {
    if(self.needRetryForOAuth) {
        return YES;
    }
    return [self.internalRequestState isRetryNeeded];
}

- (NSTimeInterval)retryAfter {
    if(self.needRetryForOAuth) {
        return 0;
    }
    return [self.internalRequestState retryAfter];
}

- (BOOL)isConnectedRequestResponseNeeded {
    if(self.needRetryForOAuth) {
        return NO;
    }
    return [self.internalRequestState isConnectedRequestResponseNeeded];
}

- (BOOL)isWaitingForResponseOfBuilder:(id<VDFRequestBuilder>)builder {
    if(self.needRetryForOAuth) {
        return NO;
    }
    return [self.internalRequestState isWaitingForResponseOfBuilder:builder];
}

- (BOOL)canHandleResponse:(VDFHttpConnectorResponse*)response ofConnectedBuilder:(id<VDFRequestBuilder>)builder {
    if(self.needRetryForOAuth) {
        return NO;
    }
    return [self.internalRequestState canHandleResponse:response ofConnectedBuilder:builder];
}

- (NSDate*)lastResponseExpirationDate {
    if(self.needRetryForOAuth) {
        return [NSDate dateWithTimeIntervalSince1970:0];
    }
    return [self.internalRequestState lastResponseExpirationDate];
}

- (NSError*)responseError {
    if(self.apixError) {
        return self.apixError;
    }
    if(self.needRetryForOAuth) {
        return nil;
    }
    return [self.internalRequestState responseError];
}

@end

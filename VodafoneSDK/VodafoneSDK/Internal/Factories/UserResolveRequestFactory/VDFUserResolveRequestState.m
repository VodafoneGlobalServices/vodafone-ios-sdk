//
//  VDFUserResolveRequestState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveRequestState.h"
#import "VDFLogUtility.h"
#import "VDFUserTokenDetails.h"
#import "VDFUserResolveRequestBuilder.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFError.h"
#import "VDFDIContainer.h"
#import "VDFBaseConfiguration.h"
#import "VDFConsts.h"
#import "VDFRequestState.h"
#import "VDFSmsValidationRequestBuilder.h"
#import "VDFRequestBuilderWithOAuth.h"

@interface VDFUserResolveRequestState ()
@property BOOL needRetry;
@property NSTimeInterval retryAfterMiliseconds;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) VDFUserResolveRequestBuilder *builder;
@property (nonatomic, assign) VDFResolutionStatus currentResolutionStatus;

- (void)readEtagFromResponse:(VDFHttpConnectorResponse*)response;
- (void)readErrorFromResponse:(VDFHttpConnectorResponse*)response;
@end

@implementation VDFUserResolveRequestState

- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder {
    self = [super init];
    if(self) {
        self.needRetry = YES; // as default this request is waiting on server changes
        self.builder = builder;
        self.retryAfterMiliseconds = -1;
        self.currentResolutionStatus = VDFResolutionStatusPending;
    }
    return self;
}

- (void)readEtagFromResponse:(VDFHttpConnectorResponse*)response {
    if(response.responseHeaders != nil && [[response.responseHeaders allKeys] containsObject:HTTP_HEADER_ETAG]) {
        NSString *etag = [response.responseHeaders objectForKey:HTTP_HEADER_ETAG];
        self.builder.eTag = etag;
    }
    
    if(self.builder.eTag == nil && self.needRetry) {
        self.builder.eTag = CHECK_STATUS_ETAG_INITIAL_VALUE; // in that case we need to set any to inform builder that we need to make first retry request
    }
}

- (void)readErrorFromResponse:(VDFHttpConnectorResponse*)response {
    if(response.httpResponseCode != 201 && response.httpResponseCode != 200 && response.httpResponseCode != 302
       && response.httpResponseCode != 404 && response.httpResponseCode != 304) {
        NSInteger errorCode = VDFErrorServerCommunication;
        if(response.httpResponseCode == 400) {
            errorCode = VDFErrorInvalidInput;
        }
        self.error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:errorCode userInfo:nil];
    }
}

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    // check for etag
    // if exists update it in builder
    if(response != nil) {
        
        self.needRetry = response.httpResponseCode == 302 || response.httpResponseCode == 304;
        
        [self readEtagFromResponse:response];
        
        if(response.responseHeaders != nil && [[response.responseHeaders allKeys] containsObject:HTTP_HEADER_RETRY_AFTER]) {
            self.retryAfterMiliseconds = [[response.responseHeaders objectForKey:HTTP_HEADER_RETRY_AFTER] doubleValue];
        }
        
        [self readErrorFromResponse:response];
    }
}

- (void)updateWithParsedResponse:(id)parsedResponse {
    
    if(parsedResponse != nil && [parsedResponse isKindOfClass:[VDFUserTokenDetails class]]) {
        
        VDFUserTokenDetails *userTokenDetails = (VDFUserTokenDetails*)parsedResponse;
        if(userTokenDetails.token != nil) {
            self.builder.sessionToken = userTokenDetails.token;
        }
        
        self.currentResolutionStatus = userTokenDetails.resolutionStatus;
    }
}

- (BOOL)isRetryNeeded {
    return self.needRetry;
}

- (NSTimeInterval)retryAfter {
    if(self.retryAfterMiliseconds > 0) {
        return self.retryAfterMiliseconds;
    }
    return ((VDFBaseConfiguration*)[self.builder.diContainer resolveForClass:[VDFBaseConfiguration class]]).httpRequestRetryTimeSpan;
}

- (BOOL)isConnectedRequestResponseNeeded {
    if(self.currentResolutionStatus == VDFResolutionStatusValidationRequired) {
        return YES; // when sms validation is needed then we waiting for aproporiate response
    }
    return NO;
}

- (void)onConnectedResponseOfBuilder:(id<VDFRequestBuilder>)builder {
    BOOL isRequiredBuilder = [builder isKindOfClass:[VDFSmsValidationRequestBuilder class]];
    if(!isRequiredBuilder) {
        isRequiredBuilder = ([builder isKindOfClass:[VDFRequestBuilderWithOAuth class]]
                             && [(VDFRequestBuilderWithOAuth*)builder isDecoratedBuilderKindOfClass:[VDFSmsValidationRequestBuilder class]]);
    }
    
    if(isRequiredBuilder) {
        if([[builder requestState] responseError] == nil) {
            // successfully validated with sms
            // we need to retry request imidettly:
            self.retryAfterMiliseconds = 0;
            self.currentResolutionStatus = VDFResolutionStatusPending;
        }
    }
}

- (BOOL)isWaitingForResponseOfBuilder:(id<VDFRequestBuilder>)builder {
    if([self isConnectedRequestResponseNeeded]) {
        if([builder isKindOfClass:[VDFRequestBuilderWithOAuth class]]) {
            return [(VDFRequestBuilderWithOAuth*)builder isDecoratedBuilderKindOfClass:[VDFSmsValidationRequestBuilder class]];
        }
        return [builder isKindOfClass:[VDFSmsValidationRequestBuilder class]];
    }
    return NO;
}

- (NSError*)responseError {
    return self.error;
}

@end

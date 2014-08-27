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

@interface VDFUserResolveRequestState ()
@property BOOL needRetry;
@property NSDate *expiresIn;
@property (nonatomic, assign) VDFUserResolveRequestBuilder *builder;
@end

@implementation VDFUserResolveRequestState

- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder {
    self = [super init];
    if(self) {
        self.needRetry = YES; // as default this request is waiting on server changes
        self.builder = builder;
    }
    return self;
}

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    // check for etag
    // if exists update it in builder
    if(response != nil && response.responseHeaders != nil && [[response.responseHeaders allKeys] containsObject:@"Etag"]) {
        self.builder.eTag = [response.responseHeaders objectForKey:@"Etag"];
    }
}

- (void)updateWithParsedResponse:(id)parsedResponse {
    
    if(parsedResponse != nil && [parsedResponse isKindOfClass:[VDFUserTokenDetails class]]) {
        
        VDFUserTokenDetails * userTokenDetails = (VDFUserTokenDetails*)parsedResponse;
        if(self.needRetry) {
            self.needRetry = userTokenDetails.stillRunning;
        }
        if(userTokenDetails.token != nil) {
            self.builder.sessionToken = userTokenDetails.token;
        }
    }
}

- (BOOL)isRetryNeeded {
    return self.needRetry;
}

- (NSDate*)lastResponseExpirationDate {
    // The user resolve response is never cached, every call schould perform server http request
    return [NSDate dateWithTimeIntervalSince1970:0];
}

@end

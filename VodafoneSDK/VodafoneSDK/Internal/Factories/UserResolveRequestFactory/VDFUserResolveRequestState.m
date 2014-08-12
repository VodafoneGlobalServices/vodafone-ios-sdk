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
#import "VDFUserResolveOptions.h"

@interface VDFUserResolveRequestState ()
@property BOOL needRetry;
@property NSDate *expiresIn;
@property (nonatomic, strong) VDFUserResolveOptions *requestOptions;
@end

@implementation VDFUserResolveRequestState

- (instancetype)initWithRequestOptionsReference:(VDFUserResolveOptions*)options {
    self = [super init];
    if(self) {
        self.requestOptions = options;
        self.needRetry = YES; // as default this request is waiting on server changes
    }
    return self;
}

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponseCode:(NSInteger)responseCode {
    // do not need this here
}

- (void)updateWithParsedResponse:(id)parsedResponse {
    VDFUserTokenDetails * userTokenDetails = nil;
    if([parsedResponse isKindOfClass:[VDFUserTokenDetails class]]) {
        userTokenDetails = (VDFUserTokenDetails*)parsedResponse;
    }
    
    if(userTokenDetails != nil) {
        if(self.needRetry) {
            self.needRetry = userTokenDetails.stillRunning;
        }
//        self.expiresIn = userTokenDetails.expires;
        if(userTokenDetails.token != nil) {
            self.requestOptions.token = userTokenDetails.token;
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

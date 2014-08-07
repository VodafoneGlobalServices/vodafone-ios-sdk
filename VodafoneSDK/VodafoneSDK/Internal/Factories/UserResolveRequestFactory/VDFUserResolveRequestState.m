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
@property BOOL satisfied;
@property NSDate *expiresIn;
@property (nonatomic, strong) VDFUserResolveOptions *requestOptions;
@end

@implementation VDFUserResolveRequestState

- (instancetype)initWithRequestOptionsReference:(VDFUserResolveOptions*)options {
    self = [super init];
    if(self) {
        self.requestOptions = options;
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
        if(!self.satisfied) {
            self.satisfied = !userTokenDetails.stillRunning;
        }
        self.expiresIn = userTokenDetails.expires;
        if(userTokenDetails.token != nil) {
            self.requestOptions.token = userTokenDetails.token;
        }
    }
}

- (BOOL)isSatisfied {
    return self.satisfied;
}

- (NSDate*)lastResponseExpirationDate {
    if(self.expiresIn == nil) {
        self.expiresIn = [NSDate dateWithTimeIntervalSinceNow:3600*24]; // default one day - TODO move to the configuration
    }
    return self.expiresIn;
}

@end

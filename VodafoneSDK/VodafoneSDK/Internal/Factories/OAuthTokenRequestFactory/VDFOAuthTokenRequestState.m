//
//  VDFOAuthTokenRequestState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenRequestState.h"
#import "VDFOAuthTokenResponse.h"

@interface VDFOAuthTokenRequestState ()
@property NSDate *expiresIn;
@end

@implementation VDFOAuthTokenRequestState

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    // if response code is another than 200 then there is an error
}

- (void)updateWithParsedResponse:(id)parsedResponse {
    if(parsedResponse != nil && [parsedResponse isKindOfClass:[VDFOAuthTokenResponse class]]) {
        VDFOAuthTokenResponse * oAuthToken = (VDFOAuthTokenResponse*)parsedResponse;
        self.expiresIn = oAuthToken.expiresIn;
    }
}

- (BOOL)isRetryNeeded {
    return NO;// not needed
}

- (NSDate*)lastResponseExpirationDate {
    if (self.expiresIn == nil) {
        // if there is some request error or not yet preformed the http request then it need to be expired
        self.expiresIn = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self.expiresIn;
}

@end

//
//  VDFOAuthTokenRequestState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenRequestState.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFError.h"
#import "VDFRequestState.h"

@interface VDFOAuthTokenRequestState ()
@property (nonatomic, strong) NSDate *expiresIn;
@property (nonatomic, assign) BOOL needRetry;
@property (nonatomic, strong) NSError *error;
@end

@implementation VDFOAuthTokenRequestState

- (void)setNeedRetryUntilFirstResponse:(BOOL)needRetry {
    self.needRetry = needRetry;
}

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    // if response code is another than 200 then there is an error
    if(response == nil || response.httpResponseCode != 200) {
        self.error = [NSError errorWithDomain:VodafoneErrorDomain code:VDFErrorOAuthTokenRetrieval userInfo:nil];
    }
    self.needRetry = NO;
}

- (void)updateWithParsedResponse:(id)parsedResponse {
    if(parsedResponse != nil && [parsedResponse isKindOfClass:[VDFOAuthTokenResponse class]]) {
        VDFOAuthTokenResponse * oAuthToken = (VDFOAuthTokenResponse*)parsedResponse;
        self.expiresIn = oAuthToken.expiresIn;
    }
}

- (BOOL)isRetryNeeded {
    return self.needRetry;// not needed
}

- (NSDate*)lastResponseExpirationDate {
    if (self.expiresIn == nil) {
        // if there is some request error or not yet preformed the http request then it need to be expired
        self.expiresIn = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return self.expiresIn;
}

- (NSError*)responseError {
    return self.error;
}

@end

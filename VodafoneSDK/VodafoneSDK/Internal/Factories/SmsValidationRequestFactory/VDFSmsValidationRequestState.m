//
//  VDFSmsValidationRequestState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationRequestState.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFError.h"

@interface VDFSmsValidationRequestState ()
@property (nonatomic, strong) NSError *error;
@end

@implementation VDFSmsValidationRequestState

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    if(response != nil && response.httpResponseCode != 200) {
        NSInteger errorCode = VDFErrorServerCommunication;
        if(response.httpResponseCode == 400) {
            errorCode = VDFErrorInvalidInput;
        }
        if(response.httpResponseCode == 404) {
            errorCode = VDFErrorTokenNotFound;
        }
        if(response.httpResponseCode == 409) {
            errorCode = VDFErrorWrongSmsCode;
        }
        self.error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:errorCode userInfo:nil];
    }
}

- (void)updateWithParsedResponse:(id)parsedResponse {
}

- (BOOL)isRetryNeeded {
    return NO; // it never need to retry because this request is not waiting for server side changes
}

- (NSTimeInterval)retryAfter {
    return 0;
}

- (NSDate*)lastResponseExpirationDate {
    return [NSDate dateWithTimeIntervalSince1970:0];// this is not cached so it expires immediately
}

- (NSError*)responseError {
    return self.error;
}

@end

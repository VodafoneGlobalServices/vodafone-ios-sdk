//
//  VDFSmsSendPinRequestState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsSendPinRequestState.h"

@implementation VDFSmsSendPinRequestState

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    // TODO
}

- (void)updateWithParsedResponse:(id)parsedResponse {
}

- (BOOL)isRetryNeeded {
    return NO; // it never need to retry because this request is not waiting for server side changes
}

- (NSDate*)lastResponseExpirationDate {
    return [NSDate date];// this is not cached so it expires immediately
}

@end
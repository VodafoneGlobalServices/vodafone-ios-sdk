//
//  VDFRequestBaseState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseState.h"

@implementation VDFRequestBaseState

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    // base method do not do nothing with it
}

- (void)updateWithParsedResponse:(id)parsedResponse {
    // base method do not do nothing with it
}

- (BOOL)isRetryNeeded {
    return NO; // default there is no any retry
}

- (NSTimeInterval)retryAfter {
    return 0;
}

- (BOOL)isConnectedRequestResponseNeeded {
    return NO;
}

- (BOOL)isWaitingForResponseOfBuilder:(id<VDFRequestBuilder>)builder {
    return NO;
}

- (BOOL)canHandleResponse:(VDFHttpConnectorResponse*)response ofConnectedBuilder:(id<VDFRequestBuilder>)builder {
    return NO;
}

- (NSDate*)lastResponseExpirationDate {
    // As default responses are never cached, every call schould perform server http request
    return [NSDate dateWithTimeIntervalSince1970:0];
}

- (NSError*)responseError {
    return nil; // as default there is no any error
}
@end

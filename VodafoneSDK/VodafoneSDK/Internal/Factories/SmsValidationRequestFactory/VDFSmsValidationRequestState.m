//
//  VDFSmsValidationRequestState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationRequestState.h"

@implementation VDFSmsValidationRequestState

#pragma mark -
#pragma mark - VDFRequestState Impelemnetation

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    // here we do nod need to store anything
}

- (void)updateWithParsedResponse:(id)parsedResponse {
}

- (BOOL)isRetryNeeded {
    return NO; // it never need to retry because this request is not waiting for server side changes
}

- (NSDate*)lastResponseExpirationDate {
    return [NSDate dateWithTimeIntervalSince1970:0];// this is not cached so it expires immediately
}

@end

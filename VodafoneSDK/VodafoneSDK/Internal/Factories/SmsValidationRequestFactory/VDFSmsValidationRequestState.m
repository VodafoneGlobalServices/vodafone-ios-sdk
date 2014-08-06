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

- (void)updateWithHttpResponseCode:(NSInteger)responseCode {
    // here we do nod need to store anything
}

- (void)updateWithParsedResponse:(id)parsedResponse {
}

- (BOOL)isSatisfied {
    return YES; // it's always satisfied because this request is not waiting for server side changes
}

- (NSDate*)lastResponseExpirationDate {
    return [NSDate date];// this is not cached so it expires immediately
}

@end

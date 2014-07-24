//
//  VDFBaseRequest.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 18/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseRequest.h"
#import "VDFStringHelper.h"

@implementation VDFBaseRequest

- (instancetype)init {
    self = [super init];
    if(self) {
        self.satisfied = YES;
    }
    return self;
}

#pragma mark -
#pragma mark VDFRequest Implementation

- (NSString*)md5Hash {
    NSString *stringToHash = [NSString stringWithFormat:@"%@%ul", [self urlEndpointMethod], [self httpMethod]];
    if([self httpMethod] == HTTPMethodPOST) {
        stringToHash = [stringToHash stringByAppendingString:[VDFStringHelper md5FromData:[self postBody]]];
    }
    return [VDFStringHelper md5FromString:stringToHash];
}

- (id<NSCoding>)parseAndUpdateOnDataResponse:(NSData*)data {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (void)onObjectResponse:(id<NSCoding>)parsedObject withError:(NSError*)error {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (void)onHttpResponseCode:(NSInteger)responseCode {
}

- (NSString*)urlEndpointMethod {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (NSDate*)expirationDate {
    if(self.expiresIn == nil) {
        self.expiresIn = [NSDate dateWithTimeIntervalSinceNow:3600*24]; // default one day - TODO move to the configuration
    }
    return self.expiresIn; // one day
}

- (BOOL)isSatisfied {
    return self.satisfied;
}

- (BOOL)isCachable {
    return NO;
}

- (BOOL)isEqualToRequest:(id<VDFRequest>)request {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (void)clearDelegateIfEquals:(id)delegate {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (BOOL)isDelegateAvailable {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (HTTPMethodType)httpMethod {
    return HTTPMethodGET;
}

- (NSData*)postBody {
    return nil;
}

@end

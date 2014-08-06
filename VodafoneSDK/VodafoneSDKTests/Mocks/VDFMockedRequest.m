//
//  VDFMockedRequest.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 01/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFMockedRequest.h"

@implementation VDFMockedRequest

- (NSString*)md5Hash {
    return self.mockMd5Hash;
}

- (id<NSCoding>)parseAndUpdateOnDataResponse:(NSData*)data {
    return nil;
}

- (void)onObjectResponse:(id<NSCoding>)parsedObject withError:(NSError*)error {
}

- (void)onHttpResponseCode:(NSInteger)responseCode {
}

- (NSString*)urlEndpointMethod {
    return self.mockUrlEndpointMethod;
}

- (NSDate*)expirationDate {
    return self.mockExpirationDate;
}

- (BOOL)isSatisfied {
    return self.mockIsSatisified;
}

- (BOOL)isCachable {
    return self.mockIsCachable;
}

- (BOOL)isGSMConnectionRequired {
    return self.mockIsGSMConnectionRequired;
}

- (BOOL)isEqualToRequest:(id<VDFRequest>)request {
    if(![request isKindOfClass:[VDFMockedRequest class]]) {
        return NO;
    }
    
    VDFMockedRequest *secondRequest = (VDFMockedRequest*)request;
    
    return [self.mockExpirationDate isEqualToDate:secondRequest.mockExpirationDate] && self.mockHttpMethod == secondRequest.mockHttpMethod
    && self.mockIsCachable == secondRequest.mockIsCachable && self.mockIsGSMConnectionRequired == secondRequest.mockIsGSMConnectionRequired
    && self.mockIsSatisified == secondRequest.mockIsSatisified && [self.mockMd5Hash isEqualToString:secondRequest.mockMd5Hash]
    && [self.mockPostBody isEqualToData:secondRequest.mockPostBody] && [self.mockUrlEndpointMethod isEqualToString:secondRequest.mockUrlEndpointMethod];
}

- (void)clearDelegateIfEquals:(id)delegate {
    if(delegate == self.mockDelegate) {
        self.mockDelegate = nil;
    }
}

- (BOOL)isDelegateAvailable {
    return self.mockDelegate != nil;
}

- (HTTPMethodType)httpMethod {
    return self.mockHttpMethod;
}

- (NSData*)postBody {
    return self.mockPostBody;
}


@end

//
//  VDFHttpConnectorResponse.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 21/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFHttpConnectorResponse.h"

@interface VDFHttpConnectorResponse ()
- (instancetype)initWithData:(NSData*)data httpCode:(NSInteger)responseCode headers:(NSDictionary*)headers error:(NSError*)error;
@end

@implementation VDFHttpConnectorResponse

- (instancetype)initWithError:(NSError*)error {
    return [self initWithData:nil httpCode:0 headers:nil error:error];
}

- (instancetype)initWithData:(NSData*)data httpCode:(NSInteger)responseCode {
    return [self initWithData:data httpCode:responseCode headers:@{} error:nil];
}

- (instancetype)initWithData:(NSData*)data httpCode:(NSInteger)responseCode headers:(NSDictionary*)headers {
    return [self initWithData:data httpCode:responseCode headers:headers error:nil];
}

- (instancetype)initWithData:(NSData *)data httpCode:(NSInteger)responseCode headers:(NSDictionary*)headers error:(NSError*)error {
    self = [super init];
    if(self) {
        self.data = data;
        self.httpResponseCode = responseCode;
        self.responseHeaders = headers;
        self.error = error;
    }
    return self;
}
@end

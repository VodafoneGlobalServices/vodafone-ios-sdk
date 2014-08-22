//
//  VDFSmsValidationResponseParser.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationResponseParser.h"
#import "VDFSmsValidationResponse.h"
#import "VDFHttpConnectorResponse.h"

static NSInteger const SuccessfulResponseCode = 200;
//static NSInteger const FailureResponseCode = 400;

@interface VDFSmsValidationResponseParser ()
@property (nonatomic, copy) NSString *smsCode;
@end

@implementation VDFSmsValidationResponseParser

- (instancetype)initWithRequestSmsCode:(NSString*)smsCode {
    self = [super init];
    if(self) {
        self.smsCode = smsCode;
    }
    return self;
}

- (id<NSCoding>)parseResponse:(VDFHttpConnectorResponse*)response {
    
    BOOL isSucceded = response.httpResponseCode == SuccessfulResponseCode;
//    if(self.responseCode == SuccessfulResponseCode) {
//        // on success we do not need to parse response
//    }
//    else if(self.responseCode == FailureResponseCode) {
//        // in case of failure we can read the status and errorMessage
//        // but for what ?
//    }

    return [[VDFSmsValidationResponse alloc] initWithSmsCode:self.smsCode isSucceded:isSucceded];
}

@end

//
//  VDFSmsValidationResponse.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationResponse.h"

@implementation VDFSmsValidationResponse

- (instancetype)initWithSmsCode:(NSString*)code isSucceded:(BOOL)isSucceded {
    self = [super init];
    if(self) {
        _isSucceded = isSucceded;
        _smsCode = [code copy];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"VDFSmsValidationResponse { isSucceded=%i, smsCode=%@ }", self.isSucceded, self.smsCode];
}

@end

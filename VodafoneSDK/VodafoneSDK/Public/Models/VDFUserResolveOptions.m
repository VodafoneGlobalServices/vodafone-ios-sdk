//
//  VDFUserResolveOptions.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveOptions.h"
#import "VDFUserResolveOptions+Internal.h"

@implementation VDFUserResolveOptions

- (instancetype)initWithSmsValidation:(BOOL)smsValidation {
    self = [super init];
    if(self) {
        self.smsValidation = smsValidation;
    }
    
    return self;
}

- (instancetype)initWithMSISDN:(NSString*)msisdn {
    self = [super init];
    if(self) {
        self.smsValidation = YES;
        self.msisdn = msisdn;
    }
    
    return self;
}

- (BOOL)isEqualToOptions:(VDFUserResolveOptions*)options {
    if(options == nil) {
        return NO;
    }
    
    BOOL result = YES;
    if(self.msisdn != nil && options.msisdn != nil) {
        result = [self.msisdn isEqualToString:options.msisdn];
    }
    else {
        result = self.msisdn == nil && options.msisdn == nil;
    }
    
    if(result) {
        if(self.market != nil && options.market != nil) {
            result = [self.market isEqualToString:options.market];
        }
        else {
            result = self.market == nil && options.market == nil;
        }
    }
    
    if(result) {
        result = self.smsValidation == options.smsValidation;
    }
    
    return result;
}

@end

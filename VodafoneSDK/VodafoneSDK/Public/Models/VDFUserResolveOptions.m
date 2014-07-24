//
//  VDFUserResolveOptions.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveOptions.h"

@implementation VDFUserResolveOptions

- (instancetype)initWithToken:(NSString*)token {
    return [self initWithToken:token validateWithSms:NO];
}

- (instancetype)initWithToken:(NSString*)token validateWithSms:(BOOL)validateWithSms {
    self = [super init];
    if(self) {
        self.token = token;
        self.validateWithSms = validateWithSms;
    }
    
    return self;
}

- (BOOL)isEqualToOptions:(VDFUserResolveOptions*)options {
    if(options == nil) {
        return NO;
    }
    
    if(![self.token isEqualToString:options.token]) {
        return NO;
    }
    
    return self.validateWithSms == options.validateWithSms;
}

#pragma mark -
#pragma mark - NSCopying Implementation
- (id)copyWithZone:(NSZone *)zone {
    VDFUserResolveOptions *newOptions = [[VDFUserResolveOptions allocWithZone:zone] init];
    newOptions.token = [self.token copyWithZone:zone];
    newOptions.validateWithSms = self.validateWithSms;
    return newOptions;
}

@end

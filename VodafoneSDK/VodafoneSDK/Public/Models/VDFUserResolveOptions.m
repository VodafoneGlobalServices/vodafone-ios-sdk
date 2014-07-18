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

#pragma mark -
#pragma mark - Base Methods Override
- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.token hash];
    result = prime * result + (self.validateWithSms)?1231:1237;
    
    return result;
}

- (BOOL)isEqual:(id)anObject {
    if (![anObject isKindOfClass:[VDFUserResolveOptions class]]) {
        return NO;
    }
    
    return [self isEqualToOptions:(VDFUserResolveOptions *)anObject];
}

@end

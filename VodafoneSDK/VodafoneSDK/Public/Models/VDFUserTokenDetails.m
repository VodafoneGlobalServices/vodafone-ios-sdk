//
//  VDFUserTokenDetails.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserTokenDetails.h"

static NSString * const ResolvedKey = @"resolved";
static NSString * const StillRunningKey = @"stillRunning";
static NSString * const TokenKey = @"token";
static NSString * const ValidationRequiredKey = @"validationRequired";
static NSString * const ExpiresInKey = @"expiresIn";

@implementation VDFUserTokenDetails

#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _resolved = [decoder decodeBoolForKey:ResolvedKey];
        _stillRunning = [decoder decodeBoolForKey:StillRunningKey];
        _token = [decoder decodeObjectForKey:TokenKey];
        _validationRequired = [decoder decodeBoolForKey:ValidationRequiredKey];
        _expiresIn = [decoder decodeObjectForKey:ExpiresInKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeBool:_resolved forKey:ResolvedKey];
    [encoder encodeBool:_stillRunning forKey:StillRunningKey];
    [encoder encodeObject:_token forKey:TokenKey];
    [encoder encodeBool:_validationRequired forKey:ValidationRequiredKey];
    [encoder encodeObject:_expiresIn forKey:ExpiresInKey];
}



@end

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

@implementation VDFUserTokenDetails

- (instancetype)initWithJsonObject:(NSDictionary*)jsonObject {
    self = [super init];
    if(self) {
        
        id resolved = [jsonObject objectForKey:ResolvedKey];
        id stillRunning = [jsonObject objectForKey:StillRunningKey];
        id token = [jsonObject objectForKey:TokenKey];
        id validationRequired = [jsonObject objectForKey:ValidationRequiredKey];
        
        if(resolved != nil && stillRunning != nil &&
           token != nil && validationRequired != nil) {
            _resolved = [resolved boolValue];
            _stillRunning = [stillRunning boolValue];
            _token = token;
            _validationRequired = [validationRequired boolValue];
        } else {
            self = nil;
        }
    }
    return self;
}

#pragma mark -
#pragma mark private implementation

//- (void)setExpiresFromString:(NSString*)expiresDateString {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
////    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
////    [dateFormatter setLocale:enUSPOSIXLocale];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
//    
////    _expires = [dateFormatter dateFromString:expiresDateString];
//}


#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _resolved = [decoder decodeBoolForKey:ResolvedKey];
        _stillRunning = [decoder decodeBoolForKey:StillRunningKey];
        _token = [decoder decodeObjectForKey:TokenKey];
        _validationRequired = [decoder decodeBoolForKey:ValidationRequiredKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeBool:_resolved forKey:ResolvedKey];
    [encoder encodeBool:_stillRunning forKey:StillRunningKey];
    [encoder encodeObject:_token forKey:TokenKey];
    [encoder encodeBool:_validationRequired forKey:ValidationRequiredKey];
}



@end

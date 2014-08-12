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
static NSString * const SourceKey = @"source";
static NSString * const TokenKey = @"token";
static NSString * const ExpiresKey = @"expires";
static NSString * const TetheringConflictKey = @"tetheringConflict";
static NSString * const ValidatedKey = @"validated";

@interface VDFUserTokenDetails ()

- (void)setExpiresFromString:(NSString*)expiresDateString;

@end

@implementation VDFUserTokenDetails

- (instancetype)initWithJsonObject:(NSDictionary*)jsonObject {
    self = [super init];
    if(self) {
        
        id resolved = [jsonObject objectForKey:ResolvedKey];
        id stillRunning = [jsonObject objectForKey:StillRunningKey];
        id source = [jsonObject objectForKey:SourceKey];
        id token = [jsonObject objectForKey:TokenKey];
        id expires = [jsonObject objectForKey:ExpiresKey];
        id tetheringConflict = [jsonObject objectForKey:TetheringConflictKey];
        id validated = [jsonObject objectForKey:ValidatedKey];
        
        if(resolved != nil && stillRunning != nil && source != nil &&
           token != nil && expires != nil && tetheringConflict != nil &&
           validated != nil) {
            _resolved = [resolved boolValue];
            _stillRunning = [stillRunning boolValue];
            _source = source;
            _token = token;
            [self setExpiresFromString:expires];
            _tetheringConflict = [tetheringConflict boolValue];
            _validated = [validated boolValue];
        } else {
            self = nil;
        }
    }
    return self;
}

#pragma mark -
#pragma mark private implementation

- (void)setExpiresFromString:(NSString*)expiresDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
//    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
//    _expires = [dateFormatter dateFromString:expiresDateString];
}


#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _resolved = [decoder decodeBoolForKey:ResolvedKey];
        _stillRunning = [decoder decodeBoolForKey:StillRunningKey];
        _source = [decoder decodeObjectForKey:SourceKey];
        _token = [decoder decodeObjectForKey:TokenKey];
//        _expires = [decoder decodeObjectForKey:ExpiresKey];
        _tetheringConflict = [decoder decodeBoolForKey:TetheringConflictKey];
        _validated = [decoder decodeBoolForKey:ValidatedKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeBool:_resolved forKey:ResolvedKey];
    [encoder encodeBool:_stillRunning forKey:StillRunningKey];
    [encoder encodeObject:_source forKey:SourceKey];
    [encoder encodeObject:_token forKey:TokenKey];
//    [encoder encodeObject:_expires forKey:ExpiresKey];
    [encoder encodeBool:_tetheringConflict forKey:TetheringConflictKey];
    [encoder encodeBool:_validated forKey:ValidatedKey];
}



@end

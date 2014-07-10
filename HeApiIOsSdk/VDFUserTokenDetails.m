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
static NSString * const ResolvedKey = @"resolved";
static NSString * const TetheringConflictKey = @"tetheringConflict";
static NSString * const ValidateKey = @"validate";

@interface VDFUserTokenDetails ()

- (void)setExpiresWithString:(NSString*)expiresDateString;

@end

@implementation VDFUserTokenDetails

- (id)initWithJsonObject:(NSDictionary*)jsonObject {
    BOOL resolved = [[jsonObject objectForKey:ResolvedKey] boolValue];
    BOOL stillRunning = [[jsonObject objectForKey:StillRunningKey] boolValue];
    NSString *source = [jsonObject objectForKey:SourceKey];
    NSString *token = [jsonObject objectForKey:TokenKey];
    NSString *expires = [jsonObject objectForKey:ExpiresKey];
    BOOL tetheringConflict = [[jsonObject objectForKey:TetheringConflictKey] boolValue];
    BOOL validate = [[jsonObject objectForKey:ValidateKey] boolValue];
    
    self.resolved = resolved;
    self.stillRunning = stillRunning;
    self.source = source;
    self.token = token;
    [self setExpiresWithString:expires];
    self.tetheringConflict = tetheringConflict;
    self.validate = validate;
}

#pragma mark -
#pragma mark private implementation

- (void)setExpiresWithString:(NSString*)expiresDateString {
    // TODO
}


@end

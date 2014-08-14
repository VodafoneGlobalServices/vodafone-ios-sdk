//
//  VDFOAuthToken.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenResponse.h"

static NSString * const AccessTokenKey = @"access_token";
static NSString * const TokenTypeKey = @"token_type";
static NSString * const ExpiresInKey = @"expires_in";

@implementation VDFOAuthTokenResponse


- (instancetype)initWithJsonObject:(NSDictionary*)jsonObject {
    self = [super init];
    if(self) {
        
        id accessToken = [jsonObject objectForKey:AccessTokenKey];
        id tokenType = [jsonObject objectForKey:TokenTypeKey];
        id expiresIn = [jsonObject objectForKey:ExpiresInKey];
        
        if(accessToken != nil && tokenType != nil && expiresIn != nil) {
            _accessToken = accessToken;
            _tokenType = tokenType;
            [NSDate dateWithTimeIntervalSinceNow:[expiresIn intValue]];
        } else {
            self = nil;
        }
    }
    return self;
}


#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    return [super init];
    // this class is no cached in files so it do not need to implement NSCoding properly
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    // this class is no cached  in files so it do not need to implement NSCoding properly
}

@end

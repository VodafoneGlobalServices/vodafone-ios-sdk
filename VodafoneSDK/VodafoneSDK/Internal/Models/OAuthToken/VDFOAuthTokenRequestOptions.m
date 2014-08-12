//
//  VDFOAuthTokenRequestOptions.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenRequestOptions.h"

@implementation VDFOAuthTokenRequestOptions


- (BOOL)isEqualToOptions:(VDFOAuthTokenRequestOptions*)options {
    if(options == nil) {
        return NO;
    }
    
    if((self.clientId == nil && options.clientId != nil) || (self.clientId != nil && options.clientId == nil)) {
        return NO;
    }
    if((self.clientSecret == nil && options.clientSecret != nil) || (self.clientSecret != nil && options.clientSecret == nil)) {
        return NO;
    }
    if((self.scopes == nil && options.scopes != nil) || (self.scopes != nil && options.scopes == nil)) {
        return NO;
    }
    
    if(self.clientId != nil && ![self.clientId isEqualToString:options.clientId]) {
        return NO;
    }
    if(self.clientSecret != nil && ![self.clientSecret isEqualToString:options.clientSecret]) {
        return NO;
    }
    if(self.scopes != nil && ![self.scopes isEqualToArray:options.scopes]) {
        return NO;
    }
    
    return YES;
}
@end

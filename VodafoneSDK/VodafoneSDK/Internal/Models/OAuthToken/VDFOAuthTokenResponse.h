//
//  VDFOAuthToken.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFOAuthTokenResponse : NSObject

/**
 *  OAuth2 token
 */
@property (nonatomic, readonly) NSString *accessToken;
/**
 *  Prefix to be used in the “Authorization” HTTP header when using this token.
 */
@property (nonatomic, readonly) NSString *tokenType;
/**
 *  Lifetime for token supplied.
 */
@property (nonatomic, readonly) NSDate *expiresIn;

@end

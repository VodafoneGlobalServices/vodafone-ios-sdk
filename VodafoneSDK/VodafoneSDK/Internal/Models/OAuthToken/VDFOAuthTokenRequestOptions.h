//
//  VDFOAuthTokenRequestOptions.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFOAuthTokenRequestOptions : NSObject

/**
 *  Mandatory: API Key associated to application
 */
@property (nonatomic, copy) NSString *clientId;
/**
 *  Mandatory: SecretKey associated to application
 */
@property (nonatomic, copy) NSString *clientSecret;
/**
 *  Mandatory: Specific API scopes.
 */
@property (nonatomic, copy) NSArray *scopes;

// TODO documentation
- (BOOL)isEqualToOptions:(VDFOAuthTokenRequestOptions*)options;

@end

//
//  VDFOAuthTokenRequestOptions.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Class of options passed to oAuthToken requests
 */
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

/**
 *  Check options for equality.
 *
 *  @param options Options object to compare with.
 *
 *  @return YES - if options object has the same values, NO - if not
 */
- (BOOL)isEqualToOptions:(VDFOAuthTokenRequestOptions*)options;

@end

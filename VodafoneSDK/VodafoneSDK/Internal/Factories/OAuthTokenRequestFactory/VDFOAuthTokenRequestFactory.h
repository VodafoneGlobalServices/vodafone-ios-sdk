//
//  VDFOAuthTokenRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"

@class VDFOAuthTokenRequestBuilder;

/**
 *  Factory of OAuthToken retrieval
 */
@interface VDFOAuthTokenRequestFactory : VDFRequestBaseFactory

/**
 *  Initialize Factory of OAuthToken.
 *
 *  @param builder Builder of OAuthToken request.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithBuilder:(VDFOAuthTokenRequestBuilder*)builder;

@end

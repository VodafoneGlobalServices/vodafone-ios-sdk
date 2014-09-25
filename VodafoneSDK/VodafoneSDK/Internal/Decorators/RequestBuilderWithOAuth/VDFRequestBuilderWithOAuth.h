//
//  VDFRequestBuilderWithOAuth.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 21/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestBuilder.h"
#import "VDFOAuthTokenRequestDelegate.h"

@class VDFRequestBaseBuilder;

/**
 *  Decorator class of requests builder which require oAuthToken.
 */
@interface VDFRequestBuilderWithOAuth : NSObject <VDFRequestBuilder, VDFOAuthTokenRequestDelegate>

/**
 *  Initialize decorator class instance.
 *
 *  @param builder  Builder object to decorate.
 *  @param selector Selector to method waiting for oAuthToken details.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithBuilder:(VDFRequestBaseBuilder*)builder oAuthTokenSetSelector:(SEL)selector;

- (void)setNeedRetryForOAuth:(BOOL)needOAuth;

- (void)updateOAuthTokenInCache:(VDFOAuthTokenResponse*)oAuthTokenDetails;

@end

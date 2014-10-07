//
//  VDFUserResolveRequestFactoryBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestBuilder.h"
#import "VDFEnums.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFRequestBaseBuilder.h"

@class VDFDIContainer, VDFUserResolveOptions, VDFOAuthTokenResponse;

/**
 *  Builder class of user resolve request.
 */
@interface VDFUserResolveRequestBuilder : VDFRequestBaseBuilder

/**
 *  Options of request.
 */
@property (nonatomic, strong) VDFUserResolveOptions *requestOptions;

/**
 *  OAuthToken details used in authorization over APIX.
 */
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;

/**
 *  Etag value used in check status calls.
 */
@property (nonatomic, strong) NSString *eTag;

/**
 *  Session token of pending user resolve process.
 */
@property (nonatomic, strong) NSString *sessionToken;

/**
 *  Initialize user resolve request builder instance.
 *
 *  @param options     Options object of request.
 *  @param diContainer Dependency injection container.
 *  @param delegate    Delegate object used as callback of request.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithOptions:(VDFUserResolveOptions*)options diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

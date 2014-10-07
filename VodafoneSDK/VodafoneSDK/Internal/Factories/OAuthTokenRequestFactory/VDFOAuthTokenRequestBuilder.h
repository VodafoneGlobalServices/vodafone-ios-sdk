//
//  VDFOAuthTokenRequestBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseBuilder.h"
#import "VDFEnums.h"
#import "VDFOAuthTokenRequestDelegate.h"

@class VDFOAuthTokenRequestOptions, VDFDIContainer;

/**
 *  Builder class of oAuthToken retrieval requests
 */
@interface VDFOAuthTokenRequestBuilder : VDFRequestBaseBuilder

/**
 *  Options of request.
 */
@property (nonatomic, strong) VDFOAuthTokenRequestOptions *requestOptions;

/**
 *  Initialize builder object of oAuthToken retrievals request.
 *
 *  @param options     Request options.
 *  @param diContainer Dependency injection container.
 *  @param delegate    Delegate object for callback purpose.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithOptions:(VDFOAuthTokenRequestOptions*)options
                    diContainer:(VDFDIContainer*)diContainer
                             delegate:(id<VDFOAuthTokenRequestDelegate>)delegate;

@end

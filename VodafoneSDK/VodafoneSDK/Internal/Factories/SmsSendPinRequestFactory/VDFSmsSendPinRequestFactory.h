//
//  VDFSmsSendPinRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"

@class VDFSmsSendPinRequestBuilder;

/**
 *  Factory of Send Pin Requests
 */
@interface VDFSmsSendPinRequestFactory : VDFRequestBaseFactory

/**
 *  Initialize factory of send pin requests.
 *
 *  @param builder Builder of send pin request.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithBuilder:(VDFSmsSendPinRequestBuilder*)builder;

@end

//
//  VDFSmsValidationRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"

@class VDFSmsValidationRequestBuilder;

/**
 *  Factory of sms code validation requests.
 */
@interface VDFSmsValidationRequestFactory : VDFRequestBaseFactory

/**
 *  Initialize factory of sms code validation requests.
 *
 *  @param builder Builder of sms code validation request.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithBuilder:(VDFSmsValidationRequestBuilder*)builder;

@end

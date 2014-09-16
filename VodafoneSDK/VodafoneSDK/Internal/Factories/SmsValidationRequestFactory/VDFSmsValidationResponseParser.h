//
//  VDFSmsValidationResponseParser.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFResponseParser.h"

/**
 *  Response parser class of sms validation calls.
 */
@interface VDFSmsValidationResponseParser : NSObject <VDFResponseParser>

/**
 *  Initialize sms valdiation response parser instance.
 *
 *  @param smsCode Sms code used to make request.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithRequestSmsCode:(NSString*)smsCode;

@end

//
//  VDFSmsValidationResponse.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Response object of validateSMSCode: method in VDFUsersService class.
 */
@interface VDFSmsValidationResponse : NSObject

/**
 *  Initialize sms validation repsonse model instance.
 *
 *  @param code       Sms of which this response corresponds.
 *  @param isSucceded Flag with result of operation.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithSmsCode:(NSString*)code isSucceded:(BOOL)isSucceded;

/**
 *  A sms code which was validated.
 */
@property (nonatomic, readonly) NSString *smsCode;

/**
 *  Flag describing operation result.
 */
@property (nonatomic, readonly) BOOL isSucceded;

@end

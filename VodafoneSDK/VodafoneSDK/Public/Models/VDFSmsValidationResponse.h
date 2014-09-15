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
@interface VDFSmsValidationResponse : NSObject <NSCoding>

// TODO documentation
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

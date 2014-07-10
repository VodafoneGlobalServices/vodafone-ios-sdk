//
//  VDFUserTokenDetails.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFUserTokenDetails : NSObject

- (id)initWithJsonObject:(NSDictionary*)jsonObject;

/*! @abstract
    True if the backend was able to determine at least one MSISDN from the incoming request */
@property (nonatomic, readonly) BOOL resolved;

/*! @abstract 
    True if there is at least one thread still running on the server side for the request 
    identified by this token.
    SMS Validation and Secure work flow are done on separate threads. */
@property (nonatomic, readonly) BOOL stillRunning;

/*! @abstract 
    Source used to determine the MSISDN of the user.
    Possible values: header, iccid */
@property (nonatomic, readonly) NSString* source;

/*! @abstract The session token used to identify this client session */
@property (nonatomic, readonly) NSString* token;

/*! @abstract
    This parameter gives the date/time until the token is considered valid on the server side.
    The format of this parameter is in ISO_8601 format. For example: 2014-07-06T04:00:33+00:00 */
@property (nonatomic, readonly) NSDate* expires;

/*! @abstract
    True in case that the ICCID was read from a SIM but the header contains a different value for 
    the MSISDN rather than the one associated with the ICCID*/
@property (nonatomic, readonly) BOOL tetheringConflict;

/*! @abstract
    True if the SMS validation was successfully performed. */
@property (nonatomic, readonly) BOOL validate;

@end

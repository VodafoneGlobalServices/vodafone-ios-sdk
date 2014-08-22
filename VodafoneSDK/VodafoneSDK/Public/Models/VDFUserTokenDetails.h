//
//  VDFUserTokenDetails.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFUserTokenDetails : NSObject <NSCoding>

/**
 *  Initializes model class with json object.
 *
 *  @param jsonObject Readed json object to the dictionary.
 *
 *  @return An initialized object, or nil if any json property is not provided and object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithJsonObject:(NSDictionary*)jsonObject;

/*! @abstract
    True if the backend was able to determine at least one MSISDN from the incoming request */
@property (nonatomic, readonly) BOOL resolved;

/*! @abstract 
    True if there is at least one thread still running on the server side for the request 
    identified by this token.
    SMS Validation and Secure work flow are done on separate threads. */
@property (nonatomic, readonly) BOOL stillRunning;

/*! @abstract The session token used to identify this client session */
@property (nonatomic, readonly) NSString *token;

/*! @abstract
    True if the SMS validation was successfully performed. */
@property (nonatomic, readonly) BOOL validationRequired;

@end

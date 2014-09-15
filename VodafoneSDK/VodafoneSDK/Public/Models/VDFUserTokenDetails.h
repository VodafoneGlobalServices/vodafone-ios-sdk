//
//  VDFUserTokenDetails.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFUserTokenDetails : NSObject <NSCoding>

/*! @abstract
    True if the backend was able to determine at least one MSISDN from the incoming request */
@property (nonatomic, assign) BOOL resolved;

/*! @abstract 
    True if there is at least one thread still running on the server side for the request 
    identified by this token.
    SMS Validation and Secure work flow are done on separate threads. */
@property (nonatomic, assign) BOOL stillRunning;

/*! @abstract The session token used to identify this client session */
@property (nonatomic, strong) NSString *token;

/*! @abstract
    True if the SMS validation was successfully performed. */
@property (nonatomic, assign) BOOL validationRequired;

@property (nonatomic, strong) NSDate *expiresIn;

@end

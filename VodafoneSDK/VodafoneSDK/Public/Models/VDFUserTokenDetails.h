//
//  VDFUserTokenDetails.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Types of statuses for user resolve process.
 */
typedef NS_ENUM(NSInteger, ResolutionStatus) {
    /**
     *  User resolve process has finished with success.
     */
    ResolutionStatusCompleted = 0,
    /**
     *  Resolution of the user identity is still ongoing. 
     *  At this stage the backend has no clraity yest if the resolution will be completed by asking for OTP validation or not.
     */
    ResolutionStatusPending,
    /**
     *  The resolution of the user indentity has failed because no MSISDN header enrichement or IMSI have been helpful.
     *  The client might try to ask the phone number to the user and proceed with the Resolve API call including it for OTP validation.
     */
    ResolutionStatusFailed,
    /**
     *  Resolution of the user identity requires OTP validation.
     *  The client SDK should proceed by calling the Generate PIN API.
     */
    ResolutionStatusValidationRequired,
};

@interface VDFUserTokenDetails : NSObject <NSCoding>

/**
 *  Status of currently pending resolve process.
 */
@property (nonatomic, assign) ResolutionStatus resolutionStatus;

/**
 *  The session token used to identify this client session 
 */
@property (nonatomic, strong) NSString *token;

/**
 *  Expiration time of session token.
 */
@property (nonatomic, strong) NSDate *expiresIn;

/**
 *  ACR of resolved user.
 */
@property (nonatomic, strong) NSString *acr;

@end

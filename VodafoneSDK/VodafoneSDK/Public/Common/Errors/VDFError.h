//
//  VDFError.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString * const VodafoneErrorDomain = @"com.vodafone.sdk";

/*!
 @typedef NS_ENUM (NSUInteger, VDFErrorCode)
 @abstract Error codes returned by the Vodafone SDK in NSError.
 
 @discussion
 These are valid only in the scope of VodafoneSDKDomain.
 */
typedef NS_ENUM(NSInteger, VDFErrorCode) {
    /*!
     There is no available connection to the internet
     */
    VDFErrorNoConnection = 0,
    /*!
     Connection to the endpoint has timeouted
     */
    VDFErrorConnectionTimeout,
    /*!
     There is no available GSM connection
     */
    VDFErrorNoGSMConnection,
    /*!
     Provided validation SMS token is invalid
     */
    VDFErrorInvalidSMSToken,
    /*!
     Problems in communication with server.
     */
    VDFErrorServerCommunication,
    /*!
     To many calls in last time period.
     */
    VDFErrorThrottlingLimitExceeded,
    /*!
     The request has not passed the input validation.
     */
    VDFErrorInvalidInput,
    /*!
     Session token used in the process has expired or was wrong.
     */
    VDFErrorTokenNotFound,
    /*!
     Wrong OTP provided error for Validate PIN.
     */
    VDFErrorWrongOTP,
    /*!
     *  Error in authorization over APIX
     */
    VDFErrorApixAuthorization,
};



//
//  VDFError.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

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
};



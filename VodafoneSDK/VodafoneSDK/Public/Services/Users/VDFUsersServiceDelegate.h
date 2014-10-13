//
//  VDFUsersServiceDelegate.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFUserTokenDetails, VDFSmsValidationResponse;
@protocol VDFUsersServiceDelegate <NSObject>

/*!
 @abstract
    Callback method intended to inform the delegate object about current status of 
    user resolving process (when error is nil). If any error occurs the error parameter 
    will be provided.
    This callback method is invoked on main thread.
 
 @param userDetails
    Received user details.
 @param error
    An error object which occurred. Error code is from Vodafone SDK domain.
 
    Error codes which may occur:
    VDFErrorNoConnection - when there is no available connection to the internet or user resolve was invoked without msisdn and there is no available GSM connection,
    VDFErrorConnectionTimeout - when connection to the endpoint has timeouted,
    VDFErrorServerCommunication - when some error occure on server side,
    VDFErrorThrottlingLimitExceeded - when limit of calls in last time period exceeds,
    VDFErrorInvalidInput - when request has not passed the input validation on server side,
    VDFErrorApixAuthorization - when error in authorization over APIX occures,
    VDFErrorMsisdnCountryNotSupported - when mobile country code included in msisdn is not supported by user resolve,
    VDFErrorOAuthTokenRetrieval - when unhandled erorr occures in oAuthToken retrieval process over APIX,
    VDFErrorOutOfVodafoneCellular - when msisdn was not provided in user resolv call and user resolve cannot be continued because device is in another cellurar network than Vodafone
 */
-(void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error;


/*!
 @abstract
    Callback method intended to inform the delegate object about successful sending
    of SMS token (when error is nil). If any error occurs the error parameter will be provided.
    This method is optional for implementation.
    This callback method is invoked on main thread.
 
 @param isSuccess
    Flag representaing is state of response. If 0 then session token was wrong but if != 0 the pin was send successfully.
 @param error
    An error object which occurred. Error code is from Vodafone SDK domain.

    Error codes which may occur:
    VDFErrorNoConnection - when there is no available connection to the internet or user resolve was invoked without msisdn and there is no available GSM connection,
    VDFErrorConnectionTimeout - when connection to the endpoint has timeouted,
    VDFErrorServerCommunication - when some error occure on server side,
    VDFErrorThrottlingLimitExceeded - when limit of calls in last time period exceeds,
    VDFErrorInvalidInput - when request has not passed the input validation on server side,
    VDFErrorTokenNotFound - when session token used in the call has expired or was wrong,
    VDFErrorApixAuthorization - when error in authorization over APIX occures,
    VDFErrorOAuthTokenRetrieval - when unhandled erorr occures in oAuthToken retrieval process over APIX
 */
- (void)didSMSPinRequested:(NSNumber*)isSuccess withError:(NSError*)error;

/*!
 @abstract
    Callback method intended to inform the delegate object about successful validation
    of SMS token (when error is nil). If any error occurs the error parameter will be provided.
    This method is optional for implementation.
    If this method is invoked in response of successfully provided sms code the method 
    didReceivedUserDetails: withError: will also be invoked because the state of user resolve 
    process has changed.
    This callback method is invoked on main thread.
 
 @param response
    Results of operation.
 @param error
    An error object which occurred. Error code is from Vodafone SDK domain.
 
    Error codes which may occur:
    VDFErrorNoConnection - when there is no available connection to the internet or user resolve was invoked without msisdn and there is no available GSM connection,
    VDFErrorConnectionTimeout - when connection to the endpoint has timeouted,
    VDFErrorServerCommunication - when some error occure on server side,
    VDFErrorThrottlingLimitExceeded - when limit of calls in last time period exceeds,
    VDFErrorInvalidInput - when request has not passed the input validation on server side,
    VDFErrorTokenNotFound - when session token used in the call has expired or was wrong,
    VDFErrorWrongSmsCode - when sms code used in the call was wrong,
    VDFErrorApixAuthorization - when error in authorization over APIX occures,
    VDFErrorOAuthTokenRetrieval - when unhandled erorr occures in oAuthToken retrieval process over APIX
 */
- (void)didValidatedSMSToken:(VDFSmsValidationResponse*)response withError:(NSError*)error;

@end

//
//  VDFUsersService.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 07/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFUsersServiceDelegate.h"

@class VDFUserResolveOptions, VDFUserTokenDetails;

/*!
 @class VDFUsersService
 
 @abstract
    Objective-C singleton class representing service for obtaining and 
    maintaining user authentication token.
 */
@interface VDFUsersService : NSObject

/*!
 @abstract
    Obtain instance of VDFUsersService class
 @return 
    Instance of VDFUsersService
 */
+ (instancetype)sharedInstance;

/*!
 @abstract
    Asynchronously starts process of determining the Vodafone customer identity 
        by performing a request to the HTTP end point POST /users/resolve.
    Initial request and response of this process will be stored for further use. This will protect
        of making unnecessary round trips to the server. Server end point methods will be invoked
        only in cases when response is not yet cached, the request is different or 
        cached data has been expired.
    Method can start only one user resolve process at the same time and its done asynchronously, 
        only when cached response is available and valid, it immediately return requested data to
        the delegate's proper method.
    The user identity resolution process involves many activities on the back-end side.
        As a result of that, there may be a number of updates to the response reported by the sdk
        to the application via the registered callback until “stillRunning” property of the server
        response is set to “false” (which denotes completion of the identity resolution process).
    For example, when specifying the smsValidation flag the callback method will be invoked two times, first with API response describing that the server waits for sms code and second with information about that the user resolving process has ended.
 
 @param options
    A VDFUserResolveOptions instance holding parameters of request.
 
 @param delegate
    The objects that acts as the delegate of the receiving VDFUsersService. The delegate must
    adopt the VDFUsersServiceDelegate protocol. The delegate is not retained.
 
 */
- (void)retrieveUserDetails:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate;

/*!
 @abstract
    Method used in user resolving process to provide response to the server with code received 
    via SMS. In case of success or failure, delegate method didValidateSMSToken: withError: will be 
    invoked with either error set to nil or error object which occurred.
 
 @param smsCode
    The pin that was received via SMS.
 */
- (void)validateSmsCode:(NSString*)smsCode;

/*!
 @abstract
 Method used in user resolving process to perform operation of sending validation code by server
 via SMS. In case of success or failure, delegate method didSMSPinRequested: withError: will be
 invoked with either error set to nil or error object which occurred.
 
 */
- (void)sendSmsPin;

/*!
 @abstract
    When a caller class register itself as a delegate in retrieveUserDetails or
    validateSMSToken process then it can be removed manually from a service by calling
    setDelegate: method if you do not want to wait longer for callback invocation.
 
 @param delegate
    The delegate object to remove from waiting for response queue.
 */
- (void)setDelegate:(id<VDFUsersServiceDelegate>)delegate;

/*!
 @abstract
 If there is pending user resolve process then it is cancelled. If there is not any pending request then method do nothing.
 */
- (void)cancelRetrieveUserDetails;

@end

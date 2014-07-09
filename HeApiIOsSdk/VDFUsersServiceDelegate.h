//
//  VDFUsersServiceDelegate.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFUserTokenDetails;
@protocol VDFUsersServiceDelegate <NSObject>

/*!
 @abstract
    Callback method intended to inform the delegate object about current status of 
    user resolving process (when error is nil). If any error occurs the error parameter 
    will be provided.
 
 @param userDetails
    Received user details.
 @param error
    An error object which occurred. Error code is from Vodafone SDK domain.
 */
-(void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error;

/*!
 @abstract
    Callback method intended to inform the delegate object about successful validation
    of SMS token (when error is nil). If any error occurs the error parameter will be provided.
    This method is optional for implementation.
    If this method is invoked in response of successfully provided sms code the method 
    didReceivedUserDetails: withError: will also be invoked because the state of user resolve 
    process has changed.
 
 @param userDetails
    A token which was validated.
 @param isSuccess
    Flag describing operation result.
 @param error
    An error object which occurred. Error code is from Vodafone SDK domain.
 */
- (void)didValidatedSMSToken:(NSString*)smsToken success:(BOOL)isSuccess withError:(NSError*)errorCode;

@end

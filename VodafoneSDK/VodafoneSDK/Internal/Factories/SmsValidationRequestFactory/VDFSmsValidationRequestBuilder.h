//
//  VDFSmsValidationRequestBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseBuilder.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFEnums.h"

@class VDFOAuthTokenResponse;

/**
 *  Builder class of sms validation request.
 */
@interface VDFSmsValidationRequestBuilder : VDFRequestBaseBuilder

/**
 *  Contextual sessiont token of user resolving process
 */
@property (nonatomic, copy) NSString *sessionToken;

/**
 *  Code received over sms.
 */
@property (nonatomic, copy) NSString *smsCode;

/**
 *  OAuth Token details used to authorization o APIX.
 */
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;

/**
 *  Initialize sms validation request builder instance.
 *
 *  @param sessionToken Session token of pending user resolve process.
 *  @param smsCode      Code received over sms for valdiation.
 *  @param diContainer  Dependency injection container.
 *  @param delegate     Delegate object used as callback of operation.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithSessionToken:(NSString*)sessionToken smsCode:(NSString*)smsCode diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

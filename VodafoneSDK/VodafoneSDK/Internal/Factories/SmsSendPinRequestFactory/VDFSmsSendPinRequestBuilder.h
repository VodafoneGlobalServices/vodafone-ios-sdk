//
//  VDFSmsSendPinRequestBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseBuilder.h"
#import "VDFEnums.h"
#import "VDFUsersServiceDelegate.h"

@class VDFOAuthTokenResponse;

/**
 *  Builder class of sms send pin requests.
 */
@interface VDFSmsSendPinRequestBuilder : VDFRequestBaseBuilder

/**
 *  Contextual session token.
 */
@property (nonatomic, copy) NSString *sessionToken;

/**
 *  OAuth token details, used to verification on server side.
 */
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;

/**
 *  Initiualize builder instance.
 *
 *  @param sessionToken Session token to use.
 *  @param diContainer  Dependency injecton container.
 *  @param delegate     Delegate object for response.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithSessionToken:(NSString*)sessionToken diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate;
@end

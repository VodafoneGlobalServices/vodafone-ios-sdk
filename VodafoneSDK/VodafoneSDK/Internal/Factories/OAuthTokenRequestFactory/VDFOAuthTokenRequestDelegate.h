//
//  VDFOAuthTokenRequestDelegate.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFOAuthTokenResponse;

/**
 *  Delegate protocol of oAuthToken response receiver.
 */
@protocol VDFOAuthTokenRequestDelegate <NSObject>

/**
 *  Callback method for oAuthToken
 *
 *  @param oAuthToken Response object with oAuthToken data.
 *  @param error      Erro object if occured or nil if operation finish with success.
 */
-(void)didReceivedOAuthToken:(VDFOAuthTokenResponse*)oAuthToken withError:(NSError*)error;

@end

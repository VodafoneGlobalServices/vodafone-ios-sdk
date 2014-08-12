//
//  VDFOAuthTokenRequestDelegate.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFOAuthToken;

// TODO documentation
@protocol VDFOAuthTokenRequestDelegate <NSObject>

-(void)didReceivedOAuthToken:(VDFOAuthToken*)oAuthToken withError:(NSError*)error;

@end

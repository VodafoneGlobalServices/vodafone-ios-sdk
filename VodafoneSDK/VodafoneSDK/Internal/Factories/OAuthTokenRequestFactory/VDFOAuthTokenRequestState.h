//
//  VDFOAuthTokenRequestState.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestState.h"

/**
 *  Request state class of OAuth token
 */
@interface VDFOAuthTokenRequestState : NSObject <VDFRequestState>

- (void)setNeedRetryUntilFirstResponse:(BOOL)needRetry;

@end

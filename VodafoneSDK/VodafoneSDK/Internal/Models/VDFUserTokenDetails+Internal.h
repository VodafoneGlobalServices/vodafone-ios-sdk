//
//  VDFUserTokenDetails_Internal.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 02/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <VodafoneSDK/VodafoneSDK.h>

@interface VDFUserTokenDetails ()

/**
 *  The session token used to identify pending resolution client session not yet avaialble to client
 */
@property (nonatomic, strong) NSString *tokenOfPendingResolution;

@end

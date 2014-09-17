//
//  VDFRequestStateOAuthAdapter.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 16/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestState.h"

@class VDFRequestBuilderWithOAuth;

/**
 *  Decorator for request states classes. Adds functionality of handling APIX error concerned to oAuthToken retrieval.
 */
@interface VDFRequestStateWithOAuth : NSObject <VDFRequestState>

/**
 *  Initialize oAuth request state decorator instance.
 *
 *  @param requestState Request state object to decorate.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithRequestState:(id<VDFRequestState>)requestState andParentBuilder:(VDFRequestBuilderWithOAuth*)builder;

@end

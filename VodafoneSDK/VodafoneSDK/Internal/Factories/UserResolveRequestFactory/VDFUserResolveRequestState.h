//
//  VDFUserResolveRequestState.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestBaseState.h"

@class VDFUserResolveOptions, VDFUserResolveRequestBuilder;

/**
 *  Holder for state of the user resolve SDK request.
 */
@interface VDFUserResolveRequestState : VDFRequestBaseState

- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder;

@end

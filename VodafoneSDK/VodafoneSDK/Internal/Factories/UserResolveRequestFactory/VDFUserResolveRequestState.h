//
//  VDFUserResolveRequestState.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestState.h"

@class VDFUserResolveOptions, VDFUserResolveRequestBuilder;

/**
 *  Holder for state of the user resolve SDK request.
 */
@interface VDFUserResolveRequestState : NSObject <VDFRequestState>

- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder;

@end

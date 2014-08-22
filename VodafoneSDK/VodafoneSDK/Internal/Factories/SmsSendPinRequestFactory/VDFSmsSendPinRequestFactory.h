//
//  VDFSmsSendPinRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"

@class VDFSmsSendPinRequestBuilder;

@interface VDFSmsSendPinRequestFactory : VDFRequestBaseFactory

- (instancetype)initWithBuilder:(VDFSmsSendPinRequestBuilder*)builder;

@end

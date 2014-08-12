//
//  VDFOAuthTokenRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"

@class VDFOAuthTokenRequestBuilder;

// TODO documentation
@interface VDFOAuthTokenRequestFactory : VDFRequestBaseFactory

- (instancetype)initWithBuilder:(VDFOAuthTokenRequestBuilder*)builder;

@end

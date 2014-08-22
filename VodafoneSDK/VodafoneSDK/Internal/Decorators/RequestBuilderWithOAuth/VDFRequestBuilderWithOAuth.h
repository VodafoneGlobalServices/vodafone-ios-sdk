//
//  VDFRequestBuilderWithOAuth.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 21/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestBuilder.h"
#import "VDFOAuthTokenRequestDelegate.h"

@class VDFRequestBaseBuilder;

@interface VDFRequestBuilderWithOAuth : NSObject <VDFRequestBuilder, VDFOAuthTokenRequestDelegate>

- (instancetype)initWithBuilder:(VDFRequestBaseBuilder*)builder oAuthTokenSetSelector:(SEL)selector;

@end

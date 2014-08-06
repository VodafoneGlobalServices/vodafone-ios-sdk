//
//  VDFSmsValidationRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"

@class VDFSmsValidationRequestBuilder;

@interface VDFSmsValidationRequestFactory : VDFRequestBaseFactory

// TODO documentation
- (instancetype)initWithBuilder:(VDFSmsValidationRequestBuilder*)builder;

@end

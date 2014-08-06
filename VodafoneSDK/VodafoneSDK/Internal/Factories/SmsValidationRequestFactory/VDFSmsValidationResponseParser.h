//
//  VDFSmsValidationResponseParser.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFResponseParser.h"

// TODO documentation
@interface VDFSmsValidationResponseParser : NSObject <VDFResponseParser>

- (instancetype)initWithRequestSmsCode:(NSString*)smsCode;

@end

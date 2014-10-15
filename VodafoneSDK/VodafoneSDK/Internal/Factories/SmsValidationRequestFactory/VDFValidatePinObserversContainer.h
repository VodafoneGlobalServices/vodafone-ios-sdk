//
//  VDFValidatePinObserversContainer.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 15/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFArrayObserversContainer.h"

@interface VDFValidatePinObserversContainer : VDFArrayObserversContainer

- (instancetype)initWithSmsCode:(NSString*)smsCode;

@end

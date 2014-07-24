//
//  VDFBaseRequest.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 18/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequest.h"

@interface VDFBaseRequest : NSObject <VDFRequest>

@property (nonatomic, assign) BOOL satisfied;
@property (nonatomic, strong) NSDate *expiresIn;

@end

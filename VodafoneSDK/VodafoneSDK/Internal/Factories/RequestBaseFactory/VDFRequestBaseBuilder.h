//
//  VDFRequestBaseBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestBuilder.h"

@class VDFBaseConfiguration;

@interface VDFRequestBaseBuilder : NSObject <VDFRequestBuilder>

// TODO documentation
@property (nonatomic, strong) VDFBaseConfiguration *configuration;
@property (nonatomic, strong) NSString *applicationId;

- (instancetype)initWithApplicationId:(NSString*)applicationId configuration:(VDFBaseConfiguration*)configuration;

@end

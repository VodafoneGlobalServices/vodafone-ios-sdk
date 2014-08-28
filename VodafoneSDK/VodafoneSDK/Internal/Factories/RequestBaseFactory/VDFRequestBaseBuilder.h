//
//  VDFRequestBaseBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestBuilder.h"

@class VDFDIContainer;

@interface VDFRequestBaseBuilder : NSObject <VDFRequestBuilder>

// TODO documentation
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) NSString *applicationId;

- (instancetype)initWithApplicationId:(NSString*)applicationId diContainer:(VDFDIContainer*)diContainer;

@end

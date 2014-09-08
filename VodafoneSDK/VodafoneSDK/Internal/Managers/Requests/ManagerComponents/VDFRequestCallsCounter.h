//
//  VDFRequestCallsCounter.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFDIContainer;

@interface VDFRequestCallsCounter : NSObject

- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer;

- (void)incrementCallType:(Class)classType;

- (BOOL)canPerformRequestOfType:(Class)classType;

@end

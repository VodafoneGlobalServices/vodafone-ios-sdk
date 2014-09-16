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

/**
 *  Base class of builders.
 */
@interface VDFRequestBaseBuilder : NSObject <VDFRequestBuilder>

/**
 *  Dependency injection container.
 */
@property (nonatomic, strong) VDFDIContainer *diContainer;

/**
 *  Client application key from Apix.
 */
@property (nonatomic, strong) NSString *clientAppKey;

/**
 *  Client application secret from Apix.
 */
@property (nonatomic, strong) NSString *clientAppSecret;

/**
 *  Backend application key from Apix.
 */
@property (nonatomic, strong) NSString *backendAppKey;

/**
 *  Initialize base class instance properites.
 *
 *  @param diContainer Dependency injection container.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer;

@end

//
//  VDFConfigurationManager.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFBaseManager.h"
#import "VDFHttpConnectorDelegate.h"

@class VDFBaseConfiguration, VDFDIContainer;

/**
 *  Manager responsible of SDK configuration versions maintanance.
 */
@interface VDFConfigurationManager : VDFBaseManager <VDFHttpConnectorDelegate>

/**
 *  Initialize Configuration manager instance.
 *
 *  @param diContainer Dependency Injection container.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer;

/**
 *  Start background request of new configuration download. If current configuration has not yet expired then nothing happends.
 */
- (void)checkForUpdate;

/**
 *  Reads current configuration, downloaded from configuration server.
 *
 *  @return Configuration object.
 */
- (VDFBaseConfiguration*)readConfiguration;

@end

//
//  VDFConfigurationDownloader.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 02/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFHttpConnectorDelegate.h"

@class VDFBaseConfiguration, VDFConfigurationUpdater;

typedef void (^ UpdateCompletionHandler)(VDFConfigurationUpdater *updater, BOOL isSucceeded);

@interface VDFConfigurationUpdater : NSObject <VDFHttpConnectorDelegate>

@property (nonatomic, strong) VDFBaseConfiguration *configurationToUpdate;

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration;

- (void)startUpdateWithCompletionHandler:(UpdateCompletionHandler)completionHandler;

@end

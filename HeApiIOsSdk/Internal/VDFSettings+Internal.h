//
//  VDFSettings+Internal.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSettings.h"

@class VDFServiceRequestsManager, VDFCacheManager, VDFBaseConfiguration;

@interface VDFSettings ()

+ (VDFServiceRequestsManager*)sharedRequestsManager;

+ (VDFCacheManager*)sharedCacheManager;

+ (VDFBaseConfiguration*)configuration;

@end

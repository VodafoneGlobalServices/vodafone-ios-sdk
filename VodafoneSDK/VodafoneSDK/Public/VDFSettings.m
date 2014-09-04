//
//  VDFSettings.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 07/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSettings.h"
#import "VDFSettings+Internal.h"
#import <CoreGraphics/CoreGraphics.h>
#import "VodafoneSDK.h"
#import "VDFServiceRequestsManager.h"
#import "VDFCacheManager.h"
#import "VDFBaseConfiguration.h"
#import "VDFErrorUtility.h"
#import "VDFLogUtility.h"
#import "VDFDIContainer.h"
#import "VDFConfigurationManager.h"

static VDFDIContainer * g_diContainer = nil;

@implementation VDFSettings

+ (void)initialize {
    if(self == [VDFSettings class]) {
        [VDFLogUtility setVerboseLevel:VODLogInfoVerboseLevelLastCallStackEntry];
        
        g_diContainer = [[VDFDIContainer alloc] init];
        
        VDFLogD(@"Loading configuration");
        
        // load application id from plist
        VDFConfigurationManager *configurationManager = [[VDFConfigurationManager alloc] initWithDIContainer:g_diContainer];
        [g_diContainer registerInstance:configurationManager forClass:[VDFConfigurationManager class]];
        
        VDFBaseConfiguration *configuration = [configurationManager readConfiguration];
        [g_diContainer registerInstance:configuration forClass:[VDFBaseConfiguration class]];
        
        configuration.applicationId = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFApplicationIdSettingKey] copy];
        configuration.sdkVersion = VDF_IOS_SDK_VERSION_STRING;
        
        VDFLogD(@"-- applicationId:%@", configuration.applicationId);
        VDFLogD(@"-- sdkVersion:%@", configuration.sdkVersion);
        VDFLogD(@"-- hapBaseUrl:%@", configuration.hapBaseUrl);
        VDFLogD(@"-- apixBaseUrl:%@", configuration.apixBaseUrl);
        
        id requestsManager = [[VDFServiceRequestsManager alloc] initWithDIContainer:g_diContainer cacheManager:[VDFSettings sharedCacheManager]];
        [g_diContainer registerInstance:requestsManager forClass:[VDFServiceRequestsManager class]];
    }
}

+ (void)initializeWithParams:(NSDictionary*)settingsDictionary {
    if(settingsDictionary != nil) {
        VDFLogD(@"Setting configuration from code");
        // chceck provided settings:
        id applicationId = [settingsDictionary objectForKey:VDFApplicationIdSettingKey];
        if(applicationId != nil && [applicationId isKindOfClass:[NSString class]]) {
            VDFBaseConfiguration *configuration = [g_diContainer resolveForClass:[VDFBaseConfiguration class]];
            configuration.applicationId = applicationId;
            VDFLogD(@"-- applicationId:%@", configuration.applicationId);
        }
    }
}

+ (NSString *)sdkVersion {
    return VDF_IOS_SDK_VERSION_STRING;
}

+ (void)subscribeDebugLogger:(id<VDFMessageLogger>)logger {
    [VDFLogUtility subscribeDebugLogger:logger];
}

+ (void)unsubscribeDebugLogger:(id<VDFMessageLogger>)logger {
    [VDFLogUtility unsubscribeDebugLogger:logger];
}

#pragma mark -
#pragma mark internal implementation

+ (VDFCacheManager*)sharedCacheManager {
    static id sharedCacheManagerInstance = nil;
    
    static dispatch_once_t onceTokenCacheManager;
    dispatch_once(&onceTokenCacheManager, ^{
        sharedCacheManagerInstance = [[VDFCacheManager alloc] initWithDIContainer:g_diContainer];
    });
    
    return sharedCacheManagerInstance;
}

+ (VDFDIContainer*)globalDIContainer {
    return g_diContainer;
}


@end

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
        [VDFLogUtility setVerboseLevel:VODLogInfoVerboseLevelBasic];
        
        g_diContainer = [[VDFDIContainer alloc] init];
        
        VDFLogD(@"Loading configuration");
        
        // load application id from plist
        VDFConfigurationManager *configurationManager = [[VDFConfigurationManager alloc] initWithDIContainer:g_diContainer];
        [g_diContainer registerInstance:configurationManager forClass:[VDFConfigurationManager class]];
        
        VDFBaseConfiguration *configuration = [configurationManager readConfiguration];
        [g_diContainer registerInstance:configuration forClass:[VDFBaseConfiguration class]];
        
        configuration.clientAppKey = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFClientAppKeySettingKey] copy];
        configuration.clientAppSecret = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFClientAppSecretSettingKey] copy];
        configuration.backendAppKey = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFBackendAppKeySettingKey] copy];
        
        // set empty string than nil:
        if(configuration.clientAppKey == nil) {
            configuration.clientAppKey = [NSString string];
        }
        if(configuration.clientAppSecret == nil) {
            configuration.clientAppSecret = [NSString string];
        }
        if(configuration.backendAppKey == nil) {
            configuration.backendAppKey = [NSString string];
        }
        
        configuration.sdkVersion = VDF_IOS_SDK_VERSION_STRING;
        
        VDFLogD(@"-- clientAppKey:%@", configuration.clientAppKey);
        VDFLogD(@"-- clientAppSecret:%@", configuration.clientAppSecret);
        VDFLogD(@"-- backendAppKey:%@", configuration.backendAppKey);
        VDFLogD(@"-- sdkVersion:%@", configuration.sdkVersion);
        VDFLogD(@"-- hapBaseUrl:%@", configuration.hapBaseUrl);
        VDFLogD(@"-- apixBaseUrl:%@", configuration.apixBaseUrl);
        
        id cacheManager = [[VDFCacheManager alloc] initWithDIContainer:g_diContainer];
        [g_diContainer registerInstance:cacheManager forClass:[VDFCacheManager class]];
        
        id requestsManager = [[VDFServiceRequestsManager alloc] initWithDIContainer:g_diContainer cacheManager:cacheManager];
        [g_diContainer registerInstance:requestsManager forClass:[VDFServiceRequestsManager class]];
    }
}

+ (void)initializeWithParams:(NSDictionary*)settingsDictionary {
    if(settingsDictionary != nil) {
        VDFLogD(@"Setting configuration from code");
        // chceck provided settings:
        id clientAppKey = [settingsDictionary objectForKey:VDFClientAppKeySettingKey];
        id clientAppSecret = [settingsDictionary objectForKey:VDFClientAppSecretSettingKey];
        id backendAppKey = [settingsDictionary objectForKey:VDFBackendAppKeySettingKey];
        
        VDFBaseConfiguration *configuration = [g_diContainer resolveForClass:[VDFBaseConfiguration class]];
        if(clientAppKey != nil && [clientAppKey isKindOfClass:[NSString class]]) {
            configuration.clientAppKey = clientAppKey;
            VDFLogD(@"-- clientAppKey:%@", configuration.clientAppKey);
        }
        if(clientAppSecret != nil && [clientAppSecret isKindOfClass:[NSString class]]) {
            configuration.clientAppSecret = clientAppSecret;
            VDFLogD(@"-- clientAppSecret:%@", configuration.clientAppSecret);
        }
        if(backendAppKey != nil && [backendAppKey isKindOfClass:[NSString class]]) {
            configuration.backendAppKey = backendAppKey;
            VDFLogD(@"-- backendAppKey:%@", configuration.backendAppKey);
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

+ (VDFDIContainer*)globalDIContainer {
    return g_diContainer;
}


@end

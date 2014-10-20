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
#import "VDFDeviceUtility.h"

static VDFDIContainer * g_diContainer = nil;

@implementation VDFSettings

+ (void)initialize {
    if(self == [VDFSettings class]) {
        g_diContainer = [[VDFDIContainer alloc] init];
        
        
        // registering VDFDeviceUtility instance
        [g_diContainer registerInstance:[[VDFDeviceUtility alloc] init] forClass:[VDFDeviceUtility class]];
        
        VDFLogD(@"Loading configuration");
        
        // load application id from plist
        VDFConfigurationManager *configurationManager = [[VDFConfigurationManager alloc] initWithDIContainer:g_diContainer];
        [g_diContainer registerInstance:configurationManager forClass:[VDFConfigurationManager class]];
        
        VDFBaseConfiguration *configuration = [configurationManager readConfiguration];
        [g_diContainer registerInstance:configuration forClass:[VDFBaseConfiguration class]];
        
        configuration.clientAppKey = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFClientAppKeySettingKey] copy];
        configuration.clientAppSecret = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFClientAppSecretSettingKey] copy];
        configuration.backendAppKey = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFBackendAppKeySettingKey] copy];
        
        VDFLogD(@"-- clientAppKey:%@", configuration.clientAppKey);
        VDFLogD(@"-- clientAppSecret:%@", configuration.clientAppSecret);
        VDFLogD(@"-- backendAppKey:%@", configuration.backendAppKey);
        VDFLogD(@"-- hapHost:%@", configuration.hapHost);
        VDFLogD(@"-- apixHost:%@", configuration.apixHost);
        VDFLogD(@"-- oAuthTokenUrlPath:%@", configuration.oAuthTokenUrlPath);
        VDFLogD(@"-- serviceBasePath:%@", configuration.serviceBasePath);
        VDFLogD(@"-- sdkVersion:%@", VDF_IOS_SDK_VERSION_STRING);
        
        id cacheManager = [[VDFCacheManager alloc] initWithDIContainer:g_diContainer];
        [g_diContainer registerInstance:cacheManager forClass:[VDFCacheManager class]];
        
        id requestsManager = [[VDFServiceRequestsManager alloc] initWithDIContainer:g_diContainer cacheManager:cacheManager];
        [g_diContainer registerInstance:requestsManager forClass:[VDFServiceRequestsManager class]];
        
        // initial check for updates:
        [configurationManager checkForUpdate];
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
            NSParameterAssert(configuration.clientAppKey == nil);
            configuration.clientAppKey = clientAppKey;
            VDFLogD(@"-- clientAppKey:%@", configuration.clientAppKey);
        }
        
        if(clientAppSecret != nil && [clientAppSecret isKindOfClass:[NSString class]]) {
            NSParameterAssert(configuration.clientAppSecret == nil);
            configuration.clientAppSecret = clientAppSecret;
            VDFLogD(@"-- clientAppSecret:%@", configuration.clientAppSecret);
        }
        if(backendAppKey != nil && [backendAppKey isKindOfClass:[NSString class]]) {
            NSParameterAssert(configuration.backendAppKey == nil);
            configuration.backendAppKey = backendAppKey;
            VDFLogD(@"-- backendAppKey:%@", configuration.backendAppKey);
        }
    }
}

+ (NSString *)sdkVersion {
    return VDF_IOS_SDK_VERSION_STRING;
}

+ (void)subscribeDebugLogger:(id<VDFMessageLogger>)logger {
    [VDFLogUtility subscribeLogger:logger];
}

+ (void)unsubscribeDebugLogger:(id<VDFMessageLogger>)logger {
    [VDFLogUtility unsubscribeLogger:logger];
}

#pragma mark -
#pragma mark internal implementation

+ (VDFDIContainer*)globalDIContainer {
    return g_diContainer;
}


@end

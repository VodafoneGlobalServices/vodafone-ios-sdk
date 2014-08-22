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

static NSString * const g_oAuthClientKey = @"I1OpZaPfBcI378Bt7PBhQySW5Setb8eb";
static NSString * const g_oAuthClientSecret = @"k4l1RXZGqMnw2cD8";
static NSString * const g_oAuthTokenScope = @"SSO_OAUTH2_INPUT";
static NSString * const g_hapBaseURL = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
//static NSString * const g_apixBaseUrl = @"https://apisit.developer.vodafone.com";
static NSString * const g_apixBaseUrl = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
static VDFBaseConfiguration * g_configuration = nil;

@implementation VDFSettings

+ (void)initialize {
    if(self == [VDFSettings class]) {
        [VDFLogUtility setVerboseLevel:VODLogInfoVerboseLevelLastCallStackEntry];
        
        VDFLogD(@"Loading configuration");
        // load application id from plist
        g_configuration = [[VDFBaseConfiguration alloc] init];
        g_configuration.applicationId = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFApplicationIdSettingKey] copy];
        g_configuration.sdkVersion = VDF_IOS_SDK_VERSION_STRING;
        g_configuration.hapBaseUrl = g_hapBaseURL;
        g_configuration.apixBaseUrl = g_apixBaseUrl;
        
        
        VDFLogD(@"-- applicationId:%@", g_configuration.applicationId);
        VDFLogD(@"-- sdkVersion:%@", g_configuration.sdkVersion);
        VDFLogD(@"-- hapBaseUrl:%@", g_configuration.hapBaseUrl);
        VDFLogD(@"-- apixBaseUrl:%@", g_configuration.apixBaseUrl);
        
        
        g_configuration.defaultHttpConnectionTimeout = 60.0; // default 60 seconds timeout
        g_configuration.httpRequestRetryTimeSpan = 1000; // default time span for retry request is 1 second
        g_configuration.maxHttpRequestRetriesCount = 100;
        
        // oAuth token retrieval configuration:
        g_configuration.oAuthTokenClientId = g_oAuthClientKey;
        g_configuration.oAuthTokenClientSecret = g_oAuthClientSecret;
        g_configuration.oAuthTokenScope = g_oAuthTokenScope;
    }
}

+ (void)initializeWithParams:(NSDictionary *)settingsDictionary {
    if(settingsDictionary) {
        VDFLogD(@"Setting configuration from code");
        // chceck provided settings:
        id applicationId = [settingsDictionary objectForKey:VDFApplicationIdSettingKey];
        if(applicationId && [applicationId isKindOfClass:[NSString class]]) {
            g_configuration.applicationId = applicationId;
        }
        VDFLogD(@"-- applicationId:%@", g_configuration.applicationId);
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

+ (VDFServiceRequestsManager*)sharedRequestsManager {
    static id sharedRequestManagerInstance = nil;
    
    static dispatch_once_t onceTokenRequestManager;
    dispatch_once(&onceTokenRequestManager, ^{
        sharedRequestManagerInstance = [[VDFServiceRequestsManager alloc] initWithConfiguration:g_configuration cacheManager:[VDFSettings sharedCacheManager]];
    });
    
    return sharedRequestManagerInstance;
}

+ (VDFCacheManager*)sharedCacheManager {
    static id sharedCacheManagerInstance = nil;
    
    static dispatch_once_t onceTokenCacheManager;
    dispatch_once(&onceTokenCacheManager, ^{
        sharedCacheManagerInstance = [[VDFCacheManager alloc] initWithConfiguration:g_configuration];
    });
    
    return sharedCacheManagerInstance;
}

+ (VDFBaseConfiguration*)configuration {
    return g_configuration;
}


@end

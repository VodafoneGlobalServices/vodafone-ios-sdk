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

static NSString * const g_oAuthClientKey = @"I1OpZaPfBcI378Bt7PBhQySW5Setb8eb";
static NSString * const g_oAuthClientSecret = @"k4l1RXZGqMnw2cD8";
static NSString * const g_oAuthTokenScope = @"SSO_OAUTH2_INPUT";
static NSString * const g_hapBaseURL = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
//static NSString * const g_apixBaseUrl = @"https://apisit.developer.vodafone.com";
static NSString * const g_apixBaseUrl = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
static VDFDIContainer * g_diContainer = nil;

@implementation VDFSettings

+ (void)initialize {
    if(self == [VDFSettings class]) {
        [VDFLogUtility setVerboseLevel:VODLogInfoVerboseLevelLastCallStackEntry];
        
        g_diContainer = [[VDFDIContainer alloc] init];
        
        VDFLogD(@"Loading configuration");
        // load application id from plist
        VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
        configuration.applicationId = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFApplicationIdSettingKey] copy];
        configuration.sdkVersion = VDF_IOS_SDK_VERSION_STRING;
        configuration.hapBaseUrl = g_hapBaseURL;
        configuration.apixBaseUrl = g_apixBaseUrl;
        
        
        VDFLogD(@"-- applicationId:%@", configuration.applicationId);
        VDFLogD(@"-- sdkVersion:%@", configuration.sdkVersion);
        VDFLogD(@"-- hapBaseUrl:%@", configuration.hapBaseUrl);
        VDFLogD(@"-- apixBaseUrl:%@", configuration.apixBaseUrl);
        
        
        configuration.defaultHttpConnectionTimeout = 60.0; // default 60 seconds timeout
        configuration.httpRequestRetryTimeSpan = 1000; // default time span for retry request is 1 second
        configuration.maxHttpRequestRetriesCount = 100;
        
        // oAuth token retrieval configuration:
        configuration.oAuthTokenClientId = g_oAuthClientKey;
        configuration.oAuthTokenClientSecret = g_oAuthClientSecret;
        configuration.oAuthTokenScope = g_oAuthTokenScope;
        
        [g_diContainer registerInstance:configuration forClass:[VDFBaseConfiguration class]];
        
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

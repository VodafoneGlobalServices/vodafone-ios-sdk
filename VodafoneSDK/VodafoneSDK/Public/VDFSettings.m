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


static NSString * const g_endpointBaseURL = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
static VDFBaseConfiguration * g_configuration = nil;

@implementation VDFSettings

+ (void)initialize {
    if(self == [VDFSettings class]) {
        // load application id from plist
        g_configuration = [[VDFBaseConfiguration alloc] init];
        g_configuration.applicationId = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFApplicationIdSettingKey] copy];
        g_configuration.sdkVersion = VDF_IOS_SDK_VERSION_STRING;
        g_configuration.endpointBaseUrl = g_endpointBaseURL;
    }
}

+ (void)initializeWithParams:(NSDictionary *)settingsDictionary {
    if(settingsDictionary) {
        // chceck provided settings:
        id applicationId = [settingsDictionary objectForKey:VDFApplicationIdSettingKey];
        if(applicationId && [applicationId isKindOfClass:[NSString class]]) {
            g_configuration.applicationId = applicationId;
        }
    }
}


+ (NSString *)sdkVersion {
    return VDF_IOS_SDK_VERSION_STRING;
}

#pragma mark -
#pragma mark internal implementation

+ (VDFServiceRequestsManager*)sharedRequestsManager {
    static id sharedRequestManagerInstance = nil;
    
    static dispatch_once_t onceTokenRequestManager;
    dispatch_once(&onceTokenRequestManager, ^{
        sharedRequestManagerInstance = [[VDFServiceRequestsManager alloc] initWithConfiguration:g_configuration];
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

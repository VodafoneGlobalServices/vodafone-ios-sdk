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


static NSString * const g_endpointBaseURL = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
static VDFBaseConfiguration * g_configuration = nil;

@implementation VDFSettings

+ (void)initialize {
    if(self == [VDFSettings class]) {
        [VDFLogUtility setVerboseLevel:VODLogInfoVerboseLevelFull];
        
        VDFLogD(@"Loading configuration");
        // load application id from plist
        g_configuration = [[VDFBaseConfiguration alloc] init];
        g_configuration.applicationId = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFApplicationIdSettingKey] copy];
        g_configuration.sdkVersion = VDF_IOS_SDK_VERSION_STRING;
        g_configuration.endpointBaseUrl = g_endpointBaseURL;
        
        VDFLogD(@"-- applicationId:%@", g_configuration.applicationId);
        VDFLogD(@"-- sdkVersion:%@", g_configuration.sdkVersion);
        VDFLogD(@"-- endpointBaseUrl:%@", g_configuration.endpointBaseUrl);
        
        // setting cache directory:
        VDFLogD(@"Configuring cache directory");
        NSError *error = nil;
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        g_configuration.cacheDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@"cache"];
        [[NSFileManager defaultManager] createDirectoryAtPath:g_configuration.cacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        [VDFErrorUtility handleInternalError:error];
        
        VDFLogD(@"-- cacheDirectoryPath:%@", g_configuration.cacheDirectoryPath);
        
        g_configuration.defaultHttpConnectionTimeout = 60.0; // default 60 seconds timeout
        g_configuration.httpRequestRetryTimeSpan = 1000; // default time span for retry request is 1 second
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

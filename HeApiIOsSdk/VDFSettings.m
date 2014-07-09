//
//  VDFSettings.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 07/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSettings.h"
#import <CoreGraphics/CoreGraphics.h>
#import "VodafoneSDK.h"



static NSString* g_applicationId = nil;
static CGFloat g_httpTimeout = 30; // default 30 seconds timeout


@implementation VDFSettings

+ (void)initialize {
    if(self == [VDFSettings class]) {
        // load application id from plist
        g_applicationId = [[[NSBundle mainBundle] objectForInfoDictionaryKey:VDFApplicationIdSettingKey] copy];
        
    }
}

+ (void)initializeWithParams:(NSDictionary *)settingsDictionary {
    if(settingsDictionary) {
        // chceck provided settings:
        id _applicationId = [settingsDictionary objectForKey:VDFApplicationIdSettingKey];
        if(_applicationId && [_applicationId isKindOfClass:[NSString class]]) {
            g_applicationId = _applicationId;
        }
    }
}


+ (NSString *)sdkVersion {
    return VDF_IOS_SDK_VERSION_STRING;
}


@end

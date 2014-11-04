//
//  VDFSettings.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 07/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFMessageLogger.h"


static NSString * const VDFClientAppKeySettingKey = @"VodafoneClientAppKey";
static NSString * const VDFClientAppSecretSettingKey = @"VodafoneClientAppSecret";
static NSString * const VDFBackendAppKeySettingKey = @"VodafoneBackendAppKey";


@interface VDFSettings : NSObject

/*!
 @abstract
 Call this method from the [UIApplicationDelegate application:didFinishLaunchingWithOptions:] method
 of the AppDelegate for your app. If you want to manually provide SDK settings use this method, you can also provide settings in yours plist file, in that case you need to call [VDFSettings class] to populate them.
 
 @param settingsDictionary Dictionary of key-value pairs where key is the setting name. Can be nil, but in that case the Vodafone Application Id needs to be provided in plist file of your app.
 
 */
+ (void)initializeWithParams:(NSDictionary*)settingsDictionary;

/*!
 @abstract
 Getting current SDK version
 
 @return String representing SDK version
 */
+ (NSString *)sdkVersion;


#ifdef DEBUG
+ (void)subscribeDebugLogger:(id)logger;
+ (void)unsubscribeDebugLogger:(id)logger;
#endif


@end

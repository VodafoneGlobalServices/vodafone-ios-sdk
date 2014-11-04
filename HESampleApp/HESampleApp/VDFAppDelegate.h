//
//  VDFAppDelegate.h
//  HESampleApp
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 Vodafone. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const BACKEND_APP_KEY_DEFAULTS_KEY = @"BackendAppKey";
static NSString * const CLIENT_APP_KEY_DEFAULTS_KEY = @"ClientAppKey";
static NSString * const CLIENT_APP_SECRET_DEFAULTS_KEY = @"ClientAppSecret";
static NSString * const PHONE_NUMBER_DEFAULTS_KEY = @"ResolvePhoneNumber";
static NSString * const SMS_VALIDATION_DEFAULTS_KEY = @"SmsValidationFlag";
static NSString * const DISPLAY_LOGS_DEFAULTS_KEY = @"DisplayLogs";

@interface VDFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

//
//  VDFAppDelegate.m
//  HESampleApp
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 Vodafone. All rights reserved.
//

#import "VDFAppDelegate.h"
#import "VDFMainViewController.h"

@implementation VDFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSDictionary *userDefaultsDefaults = @{ BACKEND_APP_KEY_DEFAULTS_KEY: @"dee663ce-7c8c-4457-b3a4-9c9c93e0c26a",
                                            CLIENT_APP_KEY_DEFAULTS_KEY: @"WCejf6WmXCw7fK07HzWMbTtJyYuEfQwc",
                                            CLIENT_APP_SECRET_DEFAULTS_KEY: @"eatguVG1CTeCvsST",
                                            PHONE_NUMBER_DEFAULTS_KEY: @"34678774201",
                                            SMS_VALIDATION_DEFAULTS_KEY: [NSNumber numberWithBool:YES],
                                            DISPLAY_LOGS_DEFAULTS_KEY: [NSNumber numberWithBool:YES] };
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
    
    VDFMainViewController *viewController = [[VDFMainViewController alloc] initWithNibName:@"MainView" bundle:nil];
    
#ifdef DEBUG
    [VDFSettings subscribeDebugLogger:viewController];
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

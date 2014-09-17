//
//  VDFConfigurationManager.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFConfigurationManager.h"
#import "VDFDIContainer.h"
#import "VDFBaseConfiguration.h"
#import "VDFBaseConfiguration+Manager.h"
#import "VDFConfigurationUpdater.h"
#import "VDFLogUtility.h"
#import "VDFErrorUtility.h"
#import "VDFConsts.h"

@interface VDFConfigurationManager ()
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) id configurationFileLock;
@property (nonatomic, strong) id updateLock;
@property (nonatomic, strong) VDFConfigurationUpdater *runningUpdater;
@property (nonatomic, strong) NSDate *lastCheckDate;

- (void)startUpdaterForConfiguration:(VDFBaseConfiguration*)configuration;
- (void)writeConfiguration:(VDFBaseConfiguration*)configuration;
- (NSString*)configurationFilePath;
@end

@implementation VDFConfigurationManager

- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer {
    self = [super init];
    if(self) {
        self.diContainer = diContainer;
        self.configurationFileLock = [[NSObject alloc] init];
        self.updateLock = [[NSObject alloc] init];
    }
    return self;
}

- (void)checkForUpdate {
    
    // read current configuration:
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    if(configuration == nil) {
        configuration = [self readConfiguration];
    }
    
    BOOL isUpdateNeeded = self.lastCheckDate == nil || [[self.lastCheckDate dateByAddingTimeInterval:configuration.configurationUpdateCheckTimeSpan] compare:[NSDate date]] == NSOrderedAscending;
    
    if(isUpdateNeeded) {
        // start update process
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @synchronized(self.updateLock) {
                if(self.runningUpdater == nil) {
                    [self startUpdaterForConfiguration:configuration];
                }
            }
        });
    }
}

- (VDFBaseConfiguration*)readConfiguration {
    VDFBaseConfiguration *configuration = nil;
    @synchronized(self.configurationFileLock) {
        @try {
            configuration = [NSKeyedUnarchiver unarchiveObjectWithFile:[self configurationFilePath]];
        }
        @catch (NSException *exception) {
            configuration = nil;
        }
        
        if(configuration == nil) {
            // configuration defaults:
            configuration = [[VDFBaseConfiguration alloc] init];
            
            // for manager usage
            configuration.configurationUpdateCheckTimeSpan = CONFIGURATION_DEFAULT_UPDATE_CHECK_TIME_SPAN;
            
            // for other properties
            configuration.hapBaseUrl = CONFIGURATION_DEFAULT_HAP_BASE_URL;
            configuration.apixBaseUrl = CONFIGURATION_DEFAULT_APIX_BASE_URL;
            
            configuration.defaultHttpConnectionTimeout = CONFIGURATION_DEFAULT_HTTP_CONNECTION_TIMEOUT;
            configuration.httpRequestRetryTimeSpan = CONFIGURATION_DEFAULT_HTTP_REQUEST_RETRY_TIME_SPAN;
            configuration.maxHttpRequestRetriesCount = CONFIGURATION_DEFAULT_MAX_HTTP_REQUEST_RETRIES_COUNT;
            configuration.requestsThrottlingLimit = CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_LIMIT;
            configuration.requestsThrottlingPeriod = CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_PERIOD;
        
            // oAuth token retrieval configuration:
            configuration.oAuthTokenClientId = CONFIGURATION_DEFAULT_OAUTH_CLIENT_ID;
            configuration.oAuthTokenClientSecret = CONFIGURATION_DEFAULT_OAUTH_CLIENT_SECRET;
            configuration.oAuthTokenScope = CONFIGURATION_DEFAULT_OAUTH_TOKEN_SCOPE;
            
            configuration.availableMarkets = @{ @"DE": @49, @"PT": @353 };
            
        }
    }
    return configuration;
}

#pragma mark -
#pragma mark - private implementation

- (void)startUpdaterForConfiguration:(VDFBaseConfiguration*)configuration {
    self.runningUpdater = [[VDFConfigurationUpdater alloc] initWithConfiguration:configuration];
    [self.runningUpdater startUpdateWithCompletionHandler:^(VDFConfigurationUpdater *updater, BOOL isSucceeded) {
        self.lastCheckDate = [NSDate date];
        if(isSucceeded) {
            [self writeConfiguration:updater.configurationToUpdate];
            [self.diContainer registerInstance:updater.configurationToUpdate forClass:[VDFBaseConfiguration class]];
        }
        self.runningUpdater = nil;
    }];
}

- (void)writeConfiguration:(VDFBaseConfiguration*)configuration {
    @synchronized(self.configurationFileLock) {
        if(configuration != nil) {
            [NSKeyedArchiver archiveRootObject:configuration toFile:[self configurationFilePath]];
        }
        else {
            [[NSFileManager defaultManager] removeItemAtPath:[self configurationFilePath] error:nil];
        }
    }
}

- (NSString*)configurationFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : [NSString string];
    return [basePath stringByAppendingPathComponent:CONFIGURATION_CACHE_FILE_NAME];
}

@end

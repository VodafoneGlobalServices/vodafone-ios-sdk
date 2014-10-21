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
    
    // start update process
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self.updateLock) {
            if(self.runningUpdater == nil) {
                [self startUpdaterForConfiguration:configuration];
            }
        }
    });
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
            
            // for other properties
            configuration.hapHost = CONFIGURATION_DEFAULT_HAP_HOST;
            configuration.apixHost = CONFIGURATION_DEFAULT_APIX_HOST;
            configuration.serviceBasePath = SERVICE_URL_DEFAULT_BASE_PATH;
            configuration.oAuthTokenUrlPath = SERVICE_URL_DEFAULT_OAUTH_TOKEN_PATH;
            
            configuration.defaultHttpConnectionTimeout = CONFIGURATION_DEFAULT_HTTP_CONNECTION_TIMEOUT;
            configuration.requestsThrottlingLimit = CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_LIMIT;
            configuration.requestsThrottlingPeriod = CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_PERIOD;
        
            // oAuth token retrieval configuration:
            configuration.oAuthTokenScope = CONFIGURATION_DEFAULT_OAUTH_TOKEN_SCOPE;
            configuration.oAuthTokenGrantType = CONFIGURATION_DEFAULT_OAUTH_TOKEN_GRANT_TYPE;
            
            configuration.availableMarkets = @{ @"PT": @351, @"IT": @39, @"DE": @49, @"ES": @34,
                                                @"IE": @353, @"NL": @31, @"GB": @44, @"RO": @40,
                                                @"HU": @36, @"GR": @30, @"MT": @356, @"AL": @355,
                                                @"CZ": @420, @"ZA": @27 };
            configuration.availableMccMnc = @[ @"26801", @"22210", @"26202", @"21401", @"27201",
                                               @"20404", @"23415", @"22601", @"21670", @"20205",
                                               @"27801", @"27602", @"23003", @"65501" ];
        }
    }
    return configuration;
}

#pragma mark -
#pragma mark - private implementation

- (void)startUpdaterForConfiguration:(VDFBaseConfiguration*)configuration {
    self.runningUpdater = [[VDFConfigurationUpdater alloc] initWithConfiguration:configuration];
    [self.runningUpdater startUpdateWithCompletionHandler:^(VDFConfigurationUpdater *updater, BOOL isSucceeded) {
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

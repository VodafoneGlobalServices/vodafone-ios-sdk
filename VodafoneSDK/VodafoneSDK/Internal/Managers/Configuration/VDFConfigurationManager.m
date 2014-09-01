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
#import "VDFHttpConnector.h"

static NSInteger const NotModifiedHttpCode = 304;
static NSInteger const VersionNumber = 1;
static NSString * const ServerUrlSchema = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com/v%i/sdk-config-ios/config.json";
static NSString * const ConfigurationFileName = @"baseConfig.dat";
static NSInteger const DefaultValidityTimeSpan = 43200; // in secodns, 12 hours

@interface VDFConfigurationManager ()
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) id configurationFileLock;
@property (nonatomic, strong) id updateLock;
@property (nonatomic, strong) VDFHttpConnector *currentHttpConnector;
@property (nonatomic, assign) BOOL isUpdating;

- (void)writeConfiguration:(VDFBaseConfiguration*)configuration;
- (NSString*)configurationFilePath;
- (BOOL)isUpdateNeededFor:(VDFBaseConfiguration*)configuration;
- (void)perfomHttpCallFor:(VDFBaseConfiguration*)configuration;
@end

@implementation VDFConfigurationManager

- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer {
    self = [super init];
    if(self) {
        self.diContainer = diContainer;
        self.configurationFileLock = [[NSObject alloc] init];
        self.updateLock = [[NSObject alloc] init];
        self.isUpdating = NO;
    }
    return self;
}

- (void)dealloc {
    if(self.currentHttpConnector != nil) {
        [self.currentHttpConnector cancelCommunication];
    }
}

- (void)checkForUpdate {
    
    // read current configuration:
    VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
    if(configuration == nil) {
        configuration = [self readConfiguration];
    }
    
    // check is current configuration still valid, or maybe expired
    if([self isUpdateNeededFor:configuration]) {
        // start update process
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @synchronized(self.updateLock) {
                if(self.currentHttpConnector != nil) {
                    [self perfomHttpCallFor:configuration];
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
            configuration = [[VDFBaseConfiguration alloc] init];
        }
    }
    return configuration;
}

#pragma mark -
#pragma mark - VDFHttpConnectorDelegate implementation

- (void)httpRequest:(VDFHttpConnector*)request onResponse:(VDFHttpConnectorResponse*)response {
    // TODO handle response
}

#pragma mark -
#pragma mark - private implementation

- (void)perfomHttpCallFor:(VDFBaseConfiguration*)configuration {
    
    self.currentHttpConnector = [[VDFHttpConnector alloc] initWithDelegate:self];
    self.currentHttpConnector.connectionTimeout = 60;
    self.currentHttpConnector.methodType = HTTPMethodGET;
    self.currentHttpConnector.url = [NSString stringWithFormat:ServerUrlSchema, VersionNumber];
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setObject:@"application/json" forKey:@"Accept"];
    if(configuration.configurationUpdateEtag != nil) {
        [headers setObject:configuration.configurationUpdateEtag forKey:@"If-None-Match"];
    }
    if(configuration.configurationLastUpdateDate != nil) {
        [headers setObject:[NSString stringWithFormat:@"%@", configuration.configurationLastUpdateDate] forKey:@"If-Modified-Since"]; // TODO
    }
    
    //    httpRequest.requestHeaders = @{: , /*@"User-Agent": [VDFSettings sdkVersion], @"Application-ID": self.builder.applicationId*/};
    self.currentHttpConnector.requestHeaders = headers;
    [self.currentHttpConnector startCommunication];
}

- (BOOL)isUpdateNeededFor:(VDFBaseConfiguration*)configuration {
    if(configuration.configurationLastUpdateDate == nil)
        return YES;
    NSInteger validationTimeSpan = configuration.configurationValidityTimeSpan;
    if(validationTimeSpan == 0) {
        validationTimeSpan = DefaultValidityTimeSpan;
    }
    
    NSDate *expirationDate = [NSDate dateWithTimeInterval:validationTimeSpan sinceDate:configuration.configurationLastUpdateDate];
    return [expirationDate compare:[NSDate date]] != NSOrderedDescending;
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
    return [basePath stringByAppendingPathComponent:ConfigurationFileName];
}

@end

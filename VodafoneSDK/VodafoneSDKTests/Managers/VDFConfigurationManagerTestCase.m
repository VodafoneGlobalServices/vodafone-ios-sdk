//
//  VDFConfigurationManagerTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 02/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFConfigurationManager.h"
#import "VDFConfigurationUpdater.h"
#import "VDFBaseConfiguration+Manager.h"
#import "VDFBaseConfiguration.h"
#import "VDFDIContainer.h"

extern void __gcov_flush();

@interface VDFConfigurationUpdater ()
@property (nonatomic, assign) UpdateCompletionHandler completionHandler;
@property (nonatomic, strong) VDFHttpConnector *httpConnector;
@end

@interface VDFConfigurationManager ()
@property (nonatomic, strong) VDFConfigurationUpdater *runningUpdater;
@property (nonatomic, strong) NSDate *lastCheckDate;

- (void)startUpdaterForConfiguration:(VDFBaseConfiguration*)configuration;
- (void)writeConfiguration:(VDFBaseConfiguration*)configuration;
- (NSString*)configurationFilePath;
@end

@interface VDFConfigurationManagerTestCase : XCTestCase
@property VDFConfigurationManager *managerToTests;
@property id managerToTestsMock;
@property id mockDIContainer;
@end

@implementation VDFConfigurationManagerTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.mockDIContainer = OCMClassMock([VDFDIContainer class]);
    self.managerToTests = [[VDFConfigurationManager alloc] initWithDIContainer:self.mockDIContainer];
    self.managerToTestsMock = OCMPartialMock(self.managerToTests);
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCheckForUpdateWhenConfigurationNotAvailable {
    
    // stub
    [[[self.mockDIContainer stub] andReturn:nil] resolveForClass:[VDFBaseConfiguration class]];
    
    // expect that the read configuration will be invoked
    [[self.managerToTestsMock expect] readConfiguration];
    
    // run
    [self.managerToTestsMock checkForUpdate];
    
    // verify
    [self.managerToTestsMock verify];
}

- (void)testCheckForUpdateWhenUpdateNeeded {
    
    // mock
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    configuration.configurationUpdateCheckTimeSpan = 3600;
    
    // stub
    [[[self.mockDIContainer stub] andReturn:configuration] resolveForClass:[VDFBaseConfiguration class]];
    
    // expect that the configuration updater will be started:
    [[self.managerToTestsMock expect] startUpdaterForConfiguration:configuration];
    
    // run
    [self.managerToTestsMock checkForUpdate];
    
    // verify
    [self.managerToTestsMock verifyWithDelay:2];
}

- (void)testCheckForUpdateWhenUpdatedNotNeeded {
    
    // mock
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    configuration.configurationUpdateCheckTimeSpan = 3600;
    
    // stub
    [[[self.mockDIContainer stub] andReturn:configuration] resolveForClass:[VDFBaseConfiguration class]];
    [[[self.managerToTestsMock stub] andReturn:[NSDate date]] lastCheckDate];
    
    // expect that the configuration updater wont be started:
    [[self.managerToTestsMock reject] startUpdaterForConfiguration:configuration];
    
    // run
    [self.managerToTestsMock checkForUpdate];
    
    // verify
    [self.managerToTestsMock verifyWithDelay:2];
}

- (void)testReadConfigurationSuccessfully {
    
    // mock
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : [NSString string];
    NSString *filePath = [basePath stringByAppendingPathComponent:@"someFile.dat"];
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    configuration.defaultHttpConnectionTimeout = 123;
    configuration.httpRequestRetryTimeSpan = 234;
    configuration.maxHttpRequestRetriesCount = 345;
    configuration.configurationLastModifiedDate = [NSDate date];
    configuration.configurationUpdateCheckTimeSpan = 456;
    [NSKeyedArchiver archiveRootObject:configuration toFile:filePath];
    
    // stub
    [[[self.managerToTestsMock stub] andReturn:filePath] configurationFilePath];
    
    // run
    VDFBaseConfiguration *readedConfiguration = [self.managerToTestsMock readConfiguration];
    
    // assert
    XCTAssertEqual(readedConfiguration.defaultHttpConnectionTimeout, configuration.defaultHttpConnectionTimeout, @"Configuration object is not properly readed.");
    XCTAssertEqual(readedConfiguration.httpRequestRetryTimeSpan, configuration.httpRequestRetryTimeSpan, @"Configuration object is not properly readed.");
    XCTAssertEqual(readedConfiguration.maxHttpRequestRetriesCount, configuration.maxHttpRequestRetriesCount, @"Configuration object is not properly readed.");
    XCTAssertEqualObjects(readedConfiguration.configurationLastModifiedDate, configuration.configurationLastModifiedDate, @"Configuration object is not properly readed.");
    XCTAssertEqual(readedConfiguration.configurationUpdateCheckTimeSpan, configuration.configurationUpdateCheckTimeSpan, @"Configuration object is not properly readed.");
}

- (void)testReadConfigurationWithException {
    
    // stub
    [[[self.managerToTestsMock stub] andReturn:@"someNoneExisitngFile.dat"] configurationFilePath];
    
    // run
    VDFBaseConfiguration *readedConfiguration = [self.managerToTestsMock readConfiguration];
    
    // assert
    XCTAssertNotNil(readedConfiguration, @"Configuration object is not properly created if exception occures.");
}

- (void)testStartUpdateConfigurationWithCompletionHandlerOnSuccess {
    
    // mock
    self.managerToTests.lastCheckDate = nil;
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    __block id mockUpdater = nil;
    
    // expect that the internal updater will be created
    [[[self.managerToTestsMock expect] andDo:^(NSInvocation *invocation) {
        
        // mock of created configuration updater
        VDFConfigurationUpdater *updater = nil;
        [invocation getArgument:&updater atIndex:2];
        mockUpdater = OCMPartialMock(updater);
        
        // stub
        [[[mockUpdater stub] andReturn:configuration] configurationToUpdate];
        
        // expect that the updater will be called with completion handler and it will be imidetly executed
        [[[mockUpdater expect] andDo:^(NSInvocation *updaterInvocation) {
            
            UpdateCompletionHandler handler = nil;
            [updaterInvocation getArgument:&handler atIndex:2];
            handler(mockUpdater, YES);
            
        }] startUpdateWithCompletionHandler:[OCMArg any]];
        
        [invocation setArgument:&mockUpdater atIndex:2];
        
        [[[self.managerToTestsMock stub] andReturn:mockUpdater] runningUpdater];
        
    }] setRunningUpdater:[OCMArg any]];
    
    // expect that the running updater will be cleared
    [[self.managerToTestsMock expect] setRunningUpdater:[OCMArg isNil]];
    
    // expect that the write configuration will be performed:
    [[self.managerToTestsMock expect] writeConfiguration:configuration];
    
    // expect that the DIcontainer will be updated
    [[self.mockDIContainer expect] registerInstance:configuration forClass:[VDFBaseConfiguration class]];
    
    // run
    [self.managerToTestsMock startUpdaterForConfiguration:configuration];
    
    // verify
    [self.managerToTestsMock verify];
    [self.mockDIContainer verify];
    [mockUpdater verify];
    
    // assert:
    XCTAssertNotNil(self.managerToTests.lastCheckDate, @"Last check date should be set");
}

- (void)testStartUpdateConfigurationWithCompletionHandlerOnFailure {
    
    // mock
    self.managerToTests.lastCheckDate = nil;
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    __block id mockUpdater = nil;
    
    // expect that the internal updater will be created
    [[[self.managerToTestsMock expect] andDo:^(NSInvocation *invocation) {
        
        // mock of created configuration updater
        VDFConfigurationUpdater *updater = nil;
        [invocation getArgument:&updater atIndex:2];
        mockUpdater = OCMPartialMock(updater);
        
        // stub
        [[[mockUpdater stub] andReturn:configuration] configurationToUpdate];
        
        // expect that the updater will be called with completion handler and it will be imidetly executed
        [[[mockUpdater expect] andDo:^(NSInvocation *updaterInvocation) {
            
            UpdateCompletionHandler handler = nil;
            [updaterInvocation getArgument:&handler atIndex:2];
            handler(mockUpdater, NO);
            
        }] startUpdateWithCompletionHandler:[OCMArg any]];
        
        [invocation setArgument:&mockUpdater atIndex:2];
        
        [[[self.managerToTestsMock stub] andReturn:mockUpdater] runningUpdater];
        
    }] setRunningUpdater:[OCMArg any]];
    
    // expect that the running updater will be cleared
    [[self.managerToTestsMock expect] setRunningUpdater:[OCMArg isNil]];
    
    // expect that the write configuration wont be performed:
    [[self.managerToTestsMock reject] writeConfiguration:configuration];
    
    // expect that the DIcontainer wont be updated
    [[self.mockDIContainer reject] registerInstance:configuration forClass:[VDFBaseConfiguration class]];
    
    // run
    [self.managerToTestsMock startUpdaterForConfiguration:configuration];
    
    // verify
    [self.managerToTestsMock verify];
    [self.mockDIContainer verify];
    [mockUpdater verify];
    
    // assert:
    XCTAssertNotNil(self.managerToTests.lastCheckDate, @"Last check date should be set");
}

- (void)testWriteConfigurationIsWrittenProperly {
    
    // mock
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : [NSString string];
    NSString *filePath = [basePath stringByAppendingPathComponent:@"someFile.dat"];
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    configuration.defaultHttpConnectionTimeout = 123;
    configuration.httpRequestRetryTimeSpan = 234;
    configuration.maxHttpRequestRetriesCount = 345;
    configuration.configurationLastModifiedDate = [NSDate date];
    configuration.configurationUpdateCheckTimeSpan = 456;
    
    // stub
    [[[self.managerToTestsMock stub] andReturn:filePath] configurationFilePath];
    
    // run
    [self.managerToTestsMock writeConfiguration:configuration];
    VDFBaseConfiguration *readedConfiguration = nil;
    
    // assert
    XCTAssertNoThrow(readedConfiguration = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath], @"Configuration file was not created properly.");
    XCTAssertEqual(readedConfiguration.defaultHttpConnectionTimeout, configuration.defaultHttpConnectionTimeout, @"Configuration object is not properly written.");
    XCTAssertEqual(readedConfiguration.httpRequestRetryTimeSpan, configuration.httpRequestRetryTimeSpan, @"Configuration object is not properly written.");
    XCTAssertEqual(readedConfiguration.maxHttpRequestRetriesCount, configuration.maxHttpRequestRetriesCount, @"Configuration object is not properly written.");
    XCTAssertEqualObjects(readedConfiguration.configurationLastModifiedDate, configuration.configurationLastModifiedDate, @"Configuration object is not properly written.");
    XCTAssertEqual(readedConfiguration.configurationUpdateCheckTimeSpan, configuration.configurationUpdateCheckTimeSpan, @"Configuration object is not properly written.");
}

- (void)testWriteConfigurationIsRemovedProperly {
    
    // mock
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : [NSString string];
    NSString *filePath = [basePath stringByAppendingPathComponent:@"someFile.dat"];
    VDFBaseConfiguration *configuration = [[VDFBaseConfiguration alloc] init];
    [NSKeyedArchiver archiveRootObject:configuration toFile:filePath];
    
    // stub
    [[[self.managerToTestsMock stub] andReturn:filePath] configurationFilePath];
    
    // run
    [self.managerToTestsMock writeConfiguration:nil];
    
    // assert
    XCTAssertFalse([[NSFileManager defaultManager] isReadableFileAtPath:filePath], @"Configuration file was not removed.");
}

- (void)testConfigurationFilePathIsCreatedProperly {
    
    // mock
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : [NSString string];
    
    // run
    NSString * path = [self.managerToTests configurationFilePath];
    
    XCTAssertTrue([path hasPrefix:basePath], @"File has invalid path");
}


@end

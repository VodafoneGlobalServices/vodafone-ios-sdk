//
//  VDFConfigurationUpdaterTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 02/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFConfigurationUpdater.h"
#import "VDFHttpConnector.h"
#import "VDFBaseConfiguration.h"
#import "VDFBaseConfiguration+Manager.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFConsts.h"

extern void __gcov_flush();

@interface VDFConfigurationUpdater ()
@property (nonatomic, assign) UpdateCompletionHandler completionHandler;
@property (nonatomic, strong) VDFHttpConnector *httpConnector;
@end

@interface VDFConfigurationUpdaterTestCase : XCTestCase
@property VDFConfigurationUpdater *updaterToTest;
@property id updaterToTestMock;
@property VDFBaseConfiguration *configurationToUpdate;
@end

@implementation VDFConfigurationUpdaterTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.configurationToUpdate = [[VDFBaseConfiguration alloc] init];
    self.updaterToTest = [[VDFConfigurationUpdater alloc] initWithConfiguration:self.configurationToUpdate];
    self.updaterToTestMock = OCMPartialMock(self.updaterToTest);
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.updaterToTestMock stopMocking];
}

- (void)testStartUpdateIsConnectorCreatedProperly {

    // mock
    UpdateCompletionHandler handler = ^(VDFConfigurationUpdater *updater, BOOL isSucceeded) { };
    self.configurationToUpdate.configurationUpdateEtag = @"some Etag";
    self.configurationToUpdate.configurationUpdateLastModified = [NSString stringWithFormat:@"%@", [NSDate date]];
    
    // run
    [self.updaterToTest startUpdateWithCompletionHandler:handler];
    
    // assert
    XCTAssertEqual(self.updaterToTest.completionHandler, handler, @"Completion handler is not set properly.");
    XCTAssertEqual(self.updaterToTest.httpConnector.methodType, HTTPMethodGET, @"Http connector method type is not set properly.");
    XCTAssertNotNil(self.updaterToTest.httpConnector.url, @"Http connector url is not set properly.");
    XCTAssertEqualObjects([self.updaterToTest.httpConnector.requestHeaders objectForKey:HTTP_HEADER_IF_NONE_MATCH], self.configurationToUpdate.configurationUpdateEtag, @"Etag was not set.");
    XCTAssertEqualObjects([self.updaterToTest.httpConnector.requestHeaders objectForKey:HTTP_HEADER_IF_MODIFIED_SINCE], self.configurationToUpdate.configurationUpdateLastModified, @"If-Modified-Since header was not set.");
}

- (void)testIsHttpConnectorStoppedOnDealloc {
    
    // mock
    id mockConnector = OCMClassMock([VDFHttpConnector class]);
    
    // expect that the http connector will be canceled
    [[mockConnector expect] cancelCommunication];
    
    // run
    @autoreleasepool {
        self.updaterToTest = [[VDFConfigurationUpdater alloc] initWithConfiguration:self.configurationToUpdate];
        self.updaterToTest.httpConnector = mockConnector;
        self.updaterToTest = nil;
    }
    
    // verify
    [mockConnector verify];
}

- (void)testHttpOnResponseWithFailure {
    
    // mock
    id mockConnector = OCMClassMock([VDFHttpConnector class]);
    id mockResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    __block BOOL handlerIsSucceded = YES;
    UpdateCompletionHandler handler = ^(VDFConfigurationUpdater *updater, BOOL isSucceeded) { handlerIsSucceded = isSucceeded; };
    
    // stub
    self.updaterToTest.completionHandler = handler;
    [[[mockResponse stub] andReturnValue:OCMOCK_VALUE(401)] httpResponseCode];
    
    // run
    [self.updaterToTest httpRequest:mockConnector onResponse:mockResponse];
    
    // assert
    XCTAssertFalse(handlerIsSucceded, @"Completion handler was not set properly");
}

- (void)testHttpOnResponseWithSuccessAndInvalidData {
    
    // mock
    NSDate *lastModification = [NSDate date];
    NSString *etag = @"some new etag";
    NSData *data = [NSData data];
    id mockConfiguration = OCMClassMock([VDFBaseConfiguration class]);
    id mockConnector = OCMClassMock([VDFHttpConnector class]);
    id mockResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    __block BOOL handlerIsSucceded = YES;
    UpdateCompletionHandler handler = ^(VDFConfigurationUpdater *updater, BOOL isSucceeded) { handlerIsSucceded = isSucceeded; };
    
    // stub
    self.updaterToTest.configurationToUpdate = mockConfiguration;
    self.updaterToTest.completionHandler = handler;
    [[[mockResponse stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    [[[mockResponse stub] andReturn:data] data];
    [[[mockResponse stub] andReturn:@{HTTP_HEADER_ETAG: etag, HTTP_HEADER_LAST_MODIFIED : [NSString stringWithFormat:@"%@", lastModification]}] responseHeaders];
    
    // expect that the configuration wont be invoked to update
    [[mockConfiguration reject] updateWithJson:[OCMArg isNotNil]];
    
    // expect that the configuration etag wont be updated
    [[mockConfiguration reject] setConfigurationUpdateEtag:[OCMArg isNotNil]];
    
    // expect that the configuration last modification wont be updated
    [[mockConfiguration reject] setConfigurationUpdateLastModified:[OCMArg isNotNil]];
    
    // run
    [self.updaterToTest httpRequest:mockConnector onResponse:mockResponse];
    
    // verify
    [mockConfiguration verify];
    
    // assert
    XCTAssertFalse(handlerIsSucceded, @"Completion handler was not invoked with proper values");
}

- (void)testHttpOnResponseWithSuccessAndValidData {
    
    // mock
    NSString *lastModification = [NSString stringWithFormat:@"%@", [NSDate date]];
    NSString *etag = @"some new etag";
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"validConfigurationUpdate" ofType:@"json"]];
    //[@"{ \"this_object_is_not_yest_described\" : true }" dataUsingEncoding:NSUTF8StringEncoding]; // TODO when we get know how this response will looks like than do this
    id mockConfiguration = OCMClassMock([VDFBaseConfiguration class]);
    id mockConnector = OCMClassMock([VDFHttpConnector class]);
    id mockResponse = OCMClassMock([VDFHttpConnectorResponse class]);
    __block BOOL handlerIsSucceded = NO;
    UpdateCompletionHandler handler = ^(VDFConfigurationUpdater *updater, BOOL isSucceeded) { handlerIsSucceded = isSucceeded; };
    
    // stub
    self.updaterToTest.configurationToUpdate = mockConfiguration;
    self.updaterToTest.completionHandler = handler;
    [[[mockResponse stub] andReturnValue:OCMOCK_VALUE(200)] httpResponseCode];
    [[[mockResponse stub] andReturn:data] data];
    [[[mockResponse stub] andReturn:@{HTTP_HEADER_ETAG: etag, HTTP_HEADER_LAST_MODIFIED : lastModification}] responseHeaders];
    
    // expect that the configuration will be invoked to update
    [[[mockConfiguration expect] andReturnValue:@YES] updateWithJson:[OCMArg isNotNil]];
    
    // expect that the configuration etag will be updated
    [[mockConfiguration expect] setConfigurationUpdateEtag:etag];
    
    // expect that the configuration last modification will be updated
    [[mockConfiguration expect] setConfigurationUpdateLastModified:lastModification];
    
    // run
    [self.updaterToTest httpRequest:mockConnector onResponse:mockResponse];
    
    // verify
    [mockConfiguration verify];
    
    // assert
    XCTAssertTrue(handlerIsSucceded, @"Completion handler was not invoked with proper values");
}

@end

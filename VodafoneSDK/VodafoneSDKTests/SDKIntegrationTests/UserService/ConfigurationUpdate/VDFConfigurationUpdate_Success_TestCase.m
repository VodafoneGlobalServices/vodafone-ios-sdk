//
//  VDFConfigurationUpdate_Success_TestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 17/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFUsersServiceBaseTestCase.h"
#import "VDFUserResolveOptions.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFUsersService.h"
#import "VDFSettings.h"

//static NSInteger const VERIFY_DELAY = 8;

@interface VDFConfigurationUpdate_Success_TestCase : VDFUsersServiceBaseTestCase

@end

@implementation VDFConfigurationUpdate_Success_TestCase

- (void)setUp
{
//    [self stubRequest:[self filterUpdateConfigurationRequest] withResponsesList:@[[super responseUpdateConfiguration200WithMaxAge:1800]]];
    
//    self.stubConfigUpdate = [NSNumber numberWithBool:NO];// we do not stub as default configuration update
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
//    [super rejectAnyNotHandledHttpCall];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


// TODO create new base test case for integration tests

- (void)_test_IsPerformingHttpCall_WhenCacheControlSetMaxAge {

    // this cannot be tested because ohttpstubs stubs also http caching mechanism
    
//    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
//    [VDFSettings initialize];
//    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
//    [VDFSettings initialize];
//    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
//    [VDFSettings initialize];
//    
//    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
}

@end

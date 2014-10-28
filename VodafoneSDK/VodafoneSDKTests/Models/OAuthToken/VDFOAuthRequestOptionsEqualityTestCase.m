//
//  VDFOAuthRequestOptionsEqualityTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 28/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFTestCase.h"
#import "VDFOAuthTokenRequestOptions.h"

@interface VDFOAuthRequestOptionsEqualityTestCase : VDFTestCase
@property VDFOAuthTokenRequestOptions *optionsToTest;
@end

@implementation VDFOAuthRequestOptionsEqualityTestCase

- (void)setUp
{
    [super setUp];
    
    self.optionsToTest = [[VDFOAuthTokenRequestOptions alloc] init];
    self.optionsToTest.clientId = @"someClientId";
    self.optionsToTest.clientSecret = @"someCLientSecret";
    self.optionsToTest.scopes = @[ @"someScope", @"someScope2" ];
    
}

- (void)test_sameObjectsEquals {
    VDFOAuthTokenRequestOptions *secondOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    secondOptions.clientId = [NSString stringWithString:self.optionsToTest.clientId];
    secondOptions.clientSecret = [NSString stringWithString:self.optionsToTest.clientSecret];
    secondOptions.scopes = @[ @"someScope", @"someScope2" ];
    
    XCTAssertTrue([self.optionsToTest isEqualToOptions:secondOptions], @"The same OAuthToken Request Options should equals.");
    XCTAssertTrue([secondOptions isEqualToOptions:self.optionsToTest], @"The same OAuthToken Request Options should equals.");
}

- (void)test_invalidObjectsNotEquals {
    VDFOAuthTokenRequestOptions *secondOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    secondOptions.clientId = [NSString stringWithString:self.optionsToTest.clientId];
    secondOptions.clientSecret = [NSString stringWithString:self.optionsToTest.clientSecret];
    secondOptions.scopes = nil;
    
    XCTAssertFalse([self.optionsToTest isEqualToOptions:nil], @"Nil should not equal to valid options object.");
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with nil scopes should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with nil scopes should not equal to valid options object.");
    
    secondOptions.clientId = nil;
    secondOptions.scopes = @[ @"someScope", @"someScope2" ];
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with nil clientId should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with nil clientId should not equal to valid options object.");
    
    secondOptions.clientSecret = nil;
    secondOptions.clientId = [NSString stringWithString:self.optionsToTest.clientId];
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with nil clientSecret should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with nil clientSecret should not equal to valid options object.");
    
    secondOptions.clientSecret = nil;
    secondOptions.clientId = [NSString stringWithString:self.optionsToTest.clientId];
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with nil clientSecret should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with nil clientSecret should not equal to valid options object.");
}

- (void)test_differentObjectsNotEquals {
    VDFOAuthTokenRequestOptions *secondOptions = [[VDFOAuthTokenRequestOptions alloc] init];
    secondOptions.clientId = [NSString stringWithString:self.optionsToTest.clientId];
    secondOptions.clientSecret = [NSString stringWithString:self.optionsToTest.clientSecret];
    secondOptions.scopes = @[ @"someScope", @"someScope23" ];
    
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with different scope should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with different scope should not equal to valid options object.");
    
    secondOptions.scopes = @[ @"someScope" ];
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with different count of scopes should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with different count of scopes should not equal to valid options object.");
    
    secondOptions.scopes = @[ @"someScope", @"someScope2" ];
    secondOptions.clientSecret = @"otherClientSecret";
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with different clientSecret should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with different clientSecret should not equal to valid options object.");
    
    secondOptions.clientSecret = [NSString stringWithString:self.optionsToTest.clientSecret];
    secondOptions.clientId = @"otherClientId";
    XCTAssertFalse([self.optionsToTest isEqualToOptions:secondOptions], @"Options object with different clientId should not equal to valid options object.");
    XCTAssertFalse([secondOptions isEqualToOptions:self.optionsToTest], @"Options object with different clientId should not equal to valid options object.");
}

@end

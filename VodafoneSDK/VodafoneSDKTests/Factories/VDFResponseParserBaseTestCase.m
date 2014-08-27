//
//  VDFResponseParserBaseTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 26/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFResponseParserBaseTestCase.h"
#import <OCMock/OCMock.h>
#import "VDFHttpConnectorResponse.h"

extern void __gcov_flush();

@implementation VDFResponseParserBaseTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)runAndExpectNilResultOnParser:(id<VDFResponseParser>)parser dataFromString:(NSString*)stringData responseCode:(NSInteger)responseCode messagePrefix:(NSString*)messagePrefix {
    
    // mock
    id responseMock = OCMClassMock([VDFHttpConnectorResponse class]);
    
    // stub
    [[[responseMock stub] andReturn:stringData!=nil ? [stringData dataUsingEncoding:NSUTF8StringEncoding]:nil] data];
    [[[responseMock stub] andReturnValue:OCMOCK_VALUE((NSInteger)responseCode)] httpResponseCode];
    
    // run & assert
    XCTAssertNil([parser parseResponse:responseMock], @"%@ should parse to nil.", messagePrefix);
}


@end

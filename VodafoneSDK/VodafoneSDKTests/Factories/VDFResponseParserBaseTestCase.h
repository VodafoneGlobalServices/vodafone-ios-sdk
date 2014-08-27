//
//  VDFResponseParserBaseTestCase.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 26/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFResponseParser.h"

@interface VDFResponseParserBaseTestCase : XCTestCase

- (void)runAndExpectNilResultOnParser:(id<VDFResponseParser>)parser dataFromString:(NSString*)stringData responseCode:(NSInteger)responseCode messagePrefix:(NSString*)messagePrefix;
@end

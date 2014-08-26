//
//  VDFResponseParser.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFHttpConnectorResponse;

/**
 *  Http responses parser protocol
 */
@protocol VDFResponseParser <NSObject>

/**
 *  Parse received data object to the model class.
 *
 *  @param response HTTP connector object holding
 *
 *  @return Parsed object or nil if parsing error occured.
 */
- (id<NSCoding>)parseResponse:(VDFHttpConnectorResponse*)response;

@end

//
//  VDFResponseParser.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Http responses parser protocol
 */
@protocol VDFResponseParser <NSObject>

/**
 *  Parse received data object to the model class.
 *
 *  @param data Data received from Http connection.
 *  @param responseCode Http code of the response
 *
 *  @return Parsed object or nil if parsing error occured.
 */
- (id<NSCoding>)parseData:(NSData*)data withHttpResponseCode:(NSInteger)responseCode;

@end

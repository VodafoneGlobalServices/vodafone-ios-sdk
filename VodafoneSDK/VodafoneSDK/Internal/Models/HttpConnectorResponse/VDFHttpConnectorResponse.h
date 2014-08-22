//
//  VDFHttpConnectorResponse.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 21/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFHttpConnectorResponse : NSObject

/**
 *  Received data or nil if some error occured.
 */
@property (nonatomic, strong) NSData *data;

@property (nonatomic, strong) NSDictionary *responseHeaders;

@property (nonatomic, assign) NSInteger httpResponseCode;

/**
 *  Error object which has occured or nil if everything is ok.
 */
@property (nonatomic, strong) NSError *error;


- (instancetype)initWithError:(NSError*)error;

- (instancetype)initWithData:(NSData*)data httpCode:(NSInteger)responseCode;

- (instancetype)initWithData:(NSData*)data httpCode:(NSInteger)responseCode headers:(NSDictionary*)headers;

@end

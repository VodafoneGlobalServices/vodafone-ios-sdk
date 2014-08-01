//
//  VDFHttpRequestDelegate.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFHttpConnector;

/**
 *  Delegate protocol of http/https requests.
 */
@protocol VDFHttpConnectorDelegate <NSObject>

/**
 *  Calback method invoked when response from server was received or some error occured.
 *
 *  @param request Request object which received response.
 *  @param data    Received data or nil if some error occured.
 *  @param error   Error object which has occured or nil if everything is ok.
 */
- (void)httpRequest:(VDFHttpConnector*)request onResponse:(NSData*)data withError:(NSError*)error;

@end

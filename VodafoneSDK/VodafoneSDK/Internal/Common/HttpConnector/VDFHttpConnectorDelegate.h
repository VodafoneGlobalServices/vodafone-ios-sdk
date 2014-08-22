//
//  VDFHttpRequestDelegate.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFHttpConnector, VDFHttpConnectorResponse;

/**
 *  Delegate protocol of http/https requests.
 */
@protocol VDFHttpConnectorDelegate <NSObject>

/**
 *  Calback method invoked when response from server was received or some error occured.
 *
 *  @param request  Request object which received response.
 *  @param response Response object with data.
 */
- (void)httpRequest:(VDFHttpConnector*)request onResponse:(VDFHttpConnectorResponse*)response;

@end

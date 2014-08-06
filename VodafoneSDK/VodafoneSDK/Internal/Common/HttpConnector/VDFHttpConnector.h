//
//  HttpRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFHttpConnectorDelegate.h"
#import "VDFEnums.h"

/**
 *  Describes single communication unit over the network.
 */
@interface VDFHttpConnector : NSObject <NSURLConnectionDelegate>

/**
 *  Url of web resource.
 */
@property (nonatomic, strong) NSString *url;
/**
 *  Body of the POST request.
 */
@property (nonatomic, strong) NSData *postBody;
/**
 *  Type of request.
 */
@property (nonatomic, assign) HTTPMethodType methodType;
/**
 *  Is GSM connection is required to performing request.
 */
@property (nonatomic, assign) BOOL isGSMConnectionRequired;
/**
 *  Timeout of http/https communication.
 */
@property (nonatomic, assign) NSTimeInterval connectionTimeout;
/**
 *  HTTP code of the latest response. 0 - if there are not available any responses.
 */
@property (nonatomic, readonly) NSInteger lastResponseCode;

/**
 *  Init method.
 *
 *  @param delegate Delegate object with implemented VDFHttpConnectorDelegate protocol.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithDelegate:(id<VDFHttpConnectorDelegate>)delegate;

/**
 *  Start http request depending on properties.
 *
 *  @return Error code (>0) if occures or 0 indicating success.
 */
- (NSInteger)startCommunication;

@end

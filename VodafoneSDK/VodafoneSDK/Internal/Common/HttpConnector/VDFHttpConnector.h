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
 *  Flag for setting redirect behaviour, if set to YES then automatic http redirect will be performed. Default is YES.
 */
@property (nonatomic, assign) BOOL allowRedirects;
/**
 *  Timeout of http/https communication.
 */
@property (nonatomic, assign) NSTimeInterval connectionTimeout;
/**
 *  HTTP code of the latest response. 0 - if there are not available any responses.
 */
@property (nonatomic, readonly) NSInteger lastResponseCode;
/**
 * Additional headers which can be added or override standard headers in the request.
 */
@property (nonatomic, strong) NSDictionary *requestHeaders;
/**
 *  If set to YES - use Cache-control header from cache responses to maintain http calls, default set to NO;
 */
@property (nonatomic, assign) BOOL useCachePolicy;

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
 *  @return NO if error occures or YES indicating successful starting http session.
 */
- (BOOL)startCommunication;

/**
 *  Cacnel pending http request, if request has ended or not started this method have no impact on connection.
 */
- (void)cancelCommunication;

/**
 *  Checks current state of pending http communication
 *
 *  @return YES - if connection is still open, NO - when connection is closed
 */
- (BOOL)isRunning;

@end

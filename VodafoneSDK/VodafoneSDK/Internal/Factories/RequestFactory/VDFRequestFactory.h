//
//  VDFRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFResponseParser.h"
#import "VDFObserversContainer.h"
#import "VDFRequestState.h"
#import "VDFHttpConnectorDelegate.h"

@class VDFHttpConnector, VDFCacheObject;

/**
 *  Protocol of Vodafone internal request factory
 */
@protocol VDFRequestFactory <NSObject>

/**
 *  Creates the http request filled with required server method parameters.
 *  Remember to set the delegate after creation of http connector.
 *  Each call to this method return new object.
 *
 *  @param delegate Delegate object
 *
 *  @return Http Connector object ready to start.
 */
- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate;

/**
 *  Creates cache object filled with cache key and default expiration time. Cache value is not set.
 *  Each call to this method return new object.
 *
 *  @return Cache object redy to read (if previously stored) or push to the cache manager.
 */
- (VDFCacheObject*)createCacheObject;

/**
 *  Creates response parser object.
 *  Each call to this method return new object.
 *
 *  @return Parser object for parsing Http responses.
 */
- (id<VDFResponseParser>)createResponseParser;

/**
 *  Getter method for current request state.
 *  Each call to this method return new object.
 *
 *  @return Current request state object.
 */
- (id<VDFRequestState>)createRequestState;

/**
 *  Creates container for observers object. This is proxy for sending responses to the waiting observers.
 *
 *  @return Object container ready to register observers.
 */
- (id<VDFObserversContainer>)createObserversContainer;

@end

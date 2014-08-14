//
//  VDFRequestFactoryBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestFactory.h"

/**
 *  Builder point of Request
 */
@protocol VDFRequestBuilder <NSObject>

- (id<VDFRequestFactory>)factory;

/**
 *  Creates response parser object.
 *  Each call to this method return only one object per each builder instance.
 *
 *  @return Parser object for parsing Http responses.
 */
- (id<VDFResponseParser>)responseParser;

/**
 *  Getter method for current request state.
 *  Each call to this method return only one object per each builder instance.
 *
 *  @return Current request state object.
 */
- (id<VDFRequestState>)requestState;

/**
 *  Creates (only one instance) of delegate container object. This is proxy for sending responses to the waiting observers.
 *
 *  @return Object container ready to register observers.
 */
- (id<VDFObserversContainer>)observersContainer;

/**
 *  Checks are two request builder for the same request
 *
 *  @param builder Builder object to compare.
 *
 *  @return YES - if they corresponds to the same request, NO - if not
 */
- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder;

@optional

/**
 *  Request which is needed to be performed before this request, response of dependent request is need to perform current request.
 *
 *  @return Request Builder object when additional call is needed or nil if is is not needed.
 */
- (id<VDFRequestBuilder>)dependentRequestBuilder;

/**
 *  Sets object and method to be called when the dependent request has finished and current request can be resumed
 *
 *  @param target   Target object.
 *  @param selector Selector of target which need to be called to perform resume of request.
 */
- (void)setResumeTarget:(id)target selector:(SEL)selector;

@end

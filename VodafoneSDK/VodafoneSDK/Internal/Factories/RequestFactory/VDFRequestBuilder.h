//
//  VDFRequestFactoryBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestFactory.h"

// TODO documentation
@protocol VDFRequestBuilder <NSObject>

- (id<VDFRequestFactory>)factory;

- (id)observer;

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

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder;

@end

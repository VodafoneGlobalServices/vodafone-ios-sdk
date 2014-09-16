//
//  VDFUserResolveRequestFactory.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"

@class VDFUserResolveRequestBuilder;

/**
 *  Factory of User Resolve Requests
 */
@interface VDFUserResolveRequestFactory : VDFRequestBaseFactory

/**
 *  Initialize user resolve requests factory instance.
 *
 *  @param builder User resolve request builder.
 *
 *  @return An initialized object, or nil if an object could not be created for some reason that would not result in an exception.
 */
- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder;

/**
 *  Creates prepared Http connector object used for check status call.
 *
 *  @param delegate Delegate object used as callback method.
 *
 *  @return Prepared http connector object.
 */
- (VDFHttpConnector*)createRetryHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate;

@end

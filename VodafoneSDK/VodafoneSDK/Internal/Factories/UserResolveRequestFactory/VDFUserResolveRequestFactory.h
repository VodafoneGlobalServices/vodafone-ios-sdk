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

// TODO documentation
- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder;

- (VDFHttpConnector*)createRetryHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate;

@end

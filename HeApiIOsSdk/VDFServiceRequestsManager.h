//
//  VDFRequestsManager.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseManager.h"
#import "VDFRequest.h"

@class VDFBaseConfiguration;

@interface VDFServiceRequestsManager : VDFBaseManager <VDFHttpRequestDelegate>

- (id)initWithConfiguration(VDFBaseConfiguration*)configuration;

- (void)performRequest:(id<VDFRequest>)request;

@end

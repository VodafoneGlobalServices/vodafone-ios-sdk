//
//  VDFRequestsManager.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseManager.h"
#import "VDFRequest.h"
#import "VDFHttpConnectorDelegate.h"
#import "VDFUsersServiceDelegate.h"

@class VDFBaseConfiguration;

@interface VDFServiceRequestsManager : VDFBaseManager <VDFHttpConnectorDelegate>

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration;

- (void)performRequest:(id<VDFRequest>)request;

- (void)clearRequestDelegate:(id<VDFUsersServiceDelegate>)requestDelegate;

@end

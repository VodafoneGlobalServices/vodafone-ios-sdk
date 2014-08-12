//
//  VDFHttpResponseHandler.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFHttpConnectorDelegate.h"
#import "VDFRequestBuilder.h"

@class VDFHttpConnector, VDFHttpConnectionsQueue, VDFCacheManager, VDFBaseConfiguration;

@interface VDFPendingRequestItem : NSObject <VDFHttpConnectorDelegate>

- (instancetype)initWithBuilder:(id<VDFRequestBuilder>)builder parentQueue:(VDFHttpConnectionsQueue*)parentQueue cacheManager:(VDFCacheManager*)cacheManager configuration:(VDFBaseConfiguration*)configuration;

// TODO documentation
@property (nonatomic, strong) id<VDFRequestBuilder> builder;
// number of all http requests made for this holder
@property (nonatomic, assign) NSInteger numberOfRetries;

- (void)startRequest;

- (void)cancelRequest;

@end

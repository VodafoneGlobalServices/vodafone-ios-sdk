//
//  VDFCacheManager.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseManager.h"
#import "VDFRequest.h"

@class VDFBaseConfiguration;
@interface VDFCacheManager : VDFBaseManager

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration;

- (BOOL)isResponseCachedForRequest:(id<VDFRequest>)request;
- (NSData*)responseForRequest:(id<VDFRequest>)request;
- (void)cacheResponseData:(NSData*)responseData forRequest:(id<VDFRequest>)request;

@end

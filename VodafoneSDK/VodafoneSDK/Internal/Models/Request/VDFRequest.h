//
//  VDFRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VDFRequest <NSCopying, NSObject>

- (NSString*)urlEndpointMethod;

- (NSTimeInterval)defaultCacheTime;

- (void)onDataResponse:(NSData*)data;

- (BOOL)isEqualToRequest:(id<VDFRequest>)request;

- (BOOL)isSatisfied;

@optional

// POST or GET
// default GET
- (NSString*)httpMethod;

- (NSData*)postBody;

// default NO
- (BOOL)isSimultenaous;

@end
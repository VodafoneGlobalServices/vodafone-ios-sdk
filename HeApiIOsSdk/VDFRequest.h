//
//  VDFRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VDFRequest <NSObject>

- (NSString*)urlEndpointMethod;

- (NSTimeInterval)defaultCacheTime;

- (void)onDataResponse:(NSData*)data;

- (BOOL)isEqualToRequest:(VDFRequest*)request;

- (BOOL)isSatisfied;

@optional

// POST or GET
// default GET
- (NSString*)httpMethod;

- (NSDictionary*)postParameters;

// default NO
- (BOOL)isSimultenaous;

@end

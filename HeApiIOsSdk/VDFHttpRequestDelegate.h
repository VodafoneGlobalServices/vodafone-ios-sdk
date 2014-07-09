//
//  VDFHttpRequestDelegate.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFHttpRequest;
@protocol VDFHttpRequestDelegate <NSObject>

- (void)httpRequest:(VDFHttpRequest*)request onResponse:(NSData*)data;

- (void)httpRequest:(VDFHttpRequest*)request errorOccurred:(NSError*)error;

@end

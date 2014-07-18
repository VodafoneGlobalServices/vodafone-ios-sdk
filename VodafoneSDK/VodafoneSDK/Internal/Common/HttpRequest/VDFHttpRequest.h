//
//  HttpRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFHttpRequestDelegate.h"

@interface VDFHttpRequest : NSObject <NSURLConnectionDelegate>

@property (strong, nonatomic) NSString* url;

- (instancetype)initWithDelegate:(id<VDFHttpRequestDelegate>)delegate;

- (void)get:(NSString*)url;

- (void)post:(NSString*)url withBody:(NSData*)body;

@end

//
//  HttpRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFHttpConnectorDelegate.h"

@interface VDFHttpConnector : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) NSTimeInterval connectionTimeout;
@property (nonatomic, readonly) NSInteger lastResponseCode;

- (instancetype)initWithDelegate:(id<VDFHttpConnectorDelegate>)delegate;

- (void)get:(NSString*)url;

- (void)post:(NSString*)url withBody:(NSData*)body;

@end

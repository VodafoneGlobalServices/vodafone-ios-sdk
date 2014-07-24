//
//  VDFHttpRequestDelegate.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFHttpConnector;
@protocol VDFHttpConnectorDelegate <NSObject>

- (void)httpRequest:(VDFHttpConnector*)request onResponse:(NSData*)data withError:(NSError*)error;

@end

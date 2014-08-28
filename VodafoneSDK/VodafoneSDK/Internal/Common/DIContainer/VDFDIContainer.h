//
//  VDFDIContainer.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 28/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Dependency Injection class
 */
@interface VDFDIContainer : NSObject

- (void)registerInstance:(id)instance forClass:(Class)classType;
- (void)registerInstance:(id)instance forProtocol:(Protocol*)protocolType;

- (id)resolveForClass:(Class)classType;
- (id)resolveForProtocol:(Protocol*)protocolType;

@end

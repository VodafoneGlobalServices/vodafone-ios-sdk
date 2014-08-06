//
//  VDFMessageLogger.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 01/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VDFMessageLogger <NSObject>

- (void)logMessage:(NSString*)message;

@end

//
//  VDFMessageLogger.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 01/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Log message type
 */
typedef NS_ENUM(NSUInteger, VDFLogMessageType) {
    /**
     *  Message is used for debug.
     */
    VDFLogMessageDebugType = 0,
    /**
     *  Message is used for information.
     */
    VDFLogMessageInfoType,
};

@protocol VDFMessageLogger <NSObject>

- (void)logMessage:(NSString*)message ofType:(VDFLogMessageType)logType;

@end

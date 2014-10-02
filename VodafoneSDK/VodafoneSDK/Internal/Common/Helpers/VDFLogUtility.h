//
//  VDFLogUtility.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 31/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFMessageLogger.h"

/**
 *  Log debug function
 *
 *  @param format String format template
 *  @param ...    Parameters of format string
 *
 *  @return void
 */
#define VDFLogD(format, ...) [VDFLogUtility logType:VDFLogMessageDebugType message:format, ##__VA_ARGS__]

/**
 *  Log info function
 *
 *  @param format String format template
 *  @param ...    Parameters of format string
 *
 *  @return void
 */
#define VDFLogI(format, ...) [VDFLogUtility logType:VDFLogMessageInfoType message:format, ##__VA_ARGS__]

/**
 *  Logging helper class
 */
@interface VDFLogUtility : NSObject

/**
 *  Send text to logger
 *
 *  @param logType Type of message to log
 *  @param format String to log
 */
+ (void)logType:(VDFLogMessageType)logType message:(NSString*)format, ...;

+ (void)subscribeLogger:(id<VDFMessageLogger>)logger;

+ (void)unsubscribeLogger:(id<VDFMessageLogger>)logger;

@end

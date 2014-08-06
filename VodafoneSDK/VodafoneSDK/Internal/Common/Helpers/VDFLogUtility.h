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
#define VDFLogD(format, ...) [VDFLogUtility dLog:format, ##__VA_ARGS__]

/**
 *  Verbose level bimap mask
 */
typedef NS_OPTIONS(NSUInteger, VODLogInfoVerboseLevel) {
    /**
     *  Basic verbose level. Logs only message.
     */
    VODLogInfoVerboseLevelBasic                 = 1 << 0,
    /**
     *  Adds top callstack entry.
     */
    VODLogInfoVerboseLevelLastCallStackEntry    = 1 << 1
};

/**
 *  Logging helper class
 */
@interface VDFLogUtility : NSObject

/**
 *  Set verbose level in displaying messages
 *
 *  @param level Verbose level
 */
+ (void)setVerboseLevel:(VODLogInfoVerboseLevel)level;

/**
 *  Send text to logger
 *
 *  @param text String to log
 */
+ (void)dLog:(NSString*)text, ...;

+ (void)subscribeDebugLogger:(id<VDFMessageLogger>)logger;

+ (void)unsubscribeDebugLogger:(id<VDFMessageLogger>)logger;

@end

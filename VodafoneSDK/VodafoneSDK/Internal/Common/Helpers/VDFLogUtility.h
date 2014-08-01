//
//  VDFLogUtility.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 31/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

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
     *  Adds caller class name to the message.
     */
    VODLogInfoVerboseLevelCallerClassName       = 1 << 1,
    /**
     *  Adds caller method name to the message.
     */
    VODLogInfoVerboseLevelCallerMethodName      = 1 << 2,
    /**
     *  Adds caller code line number to the message.
     */
    VODLogInfoVerboseLevelCallerLineNumber      = 1 << 3,
    /**
     *  Adds caller memory address to the message.
     */
    VODLogInfoVerboseLevelCallerMemoryAddress   = 1 << 4,
    /**
     *  Adds all available debug information to the message
     */
    VODLogInfoVerboseLevelFull                  = (1<<1) | (1<<2) | (1<<3) | (1<<4)
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

@end

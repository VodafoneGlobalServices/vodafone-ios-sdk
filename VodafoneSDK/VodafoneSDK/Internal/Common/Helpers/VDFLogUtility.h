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

typedef NS_OPTIONS(NSUInteger, VODLogInfoVerboseLevel) {
    VODLogInfoVerboseLevelBasic                 = 1 << 0,
    VODLogInfoVerboseLevelCallerClassName       = 1 << 1,
    VODLogInfoVerboseLevelCallerMethodName      = 1 << 2,
    VODLogInfoVerboseLevelCallerLineNumber      = 1 << 3,
    VODLogInfoVerboseLevelCallerMemoryAddress   = 1 << 4,
    VODLogInfoVerboseLevelFull                  = (1<<1) | (1<<2) | (1<<3) | (1<<4)
};


@interface VDFLogUtility : NSObject

+ (void)setVerboseLevel:(VODLogInfoVerboseLevel)level;

+ (void)dLog:(NSString*)text, ...;

@end

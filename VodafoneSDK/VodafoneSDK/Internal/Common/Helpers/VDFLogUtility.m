//
//  VDFLogUtility.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 31/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFLogUtility.h"

static VODLogInfoVerboseLevel g_verboseLevel = VODLogInfoVerboseLevelBasic;
static NSMutableArray * g_debugLoggers = nil;

@implementation VDFLogUtility

+ (void)initialize {
    if (self == [VDFLogUtility self]) {
        g_debugLoggers = [[NSMutableArray alloc] init];
    }
}

+ (void)setVerboseLevel:(VODLogInfoVerboseLevel)level {
    g_verboseLevel = level;
}

+ (void)dLog:(NSString*)format, ...
{
    va_list arguments;
    va_start(arguments, format);
    
    // composing log message:
    NSMutableString *logMessage = [[NSMutableString alloc] init];
    
    if(g_verboseLevel & VODLogInfoVerboseLevelLastCallStackEntry) {
        NSArray *callstack = [NSThread callStackSymbols];
        if([callstack count] > 1) {
            [logMessage appendFormat:@"%@ ", [callstack objectAtIndex:1]];
        }
    }
    
    if(g_verboseLevel != VODLogInfoVerboseLevelBasic) {
        [logMessage appendString:@"\n"];
    }
    
    [logMessage appendString:[[NSString alloc] initWithFormat:format arguments:arguments]];
    
    for (id<VDFMessageLogger> logger in g_debugLoggers) {
        [logger logMessage:logMessage];
    }
}

+ (void)subscribeDebugLogger:(id<VDFMessageLogger>)logger {
    [g_debugLoggers addObject:logger];
}

+ (void)unsubscribeDebugLogger:(id<VDFMessageLogger>)logger {
    [g_debugLoggers removeObject:logger];
}

@end

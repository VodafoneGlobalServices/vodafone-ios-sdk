//
//  VDFLogUtility.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 31/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFLogUtility.h"

static NSMutableArray * g_loggers = nil;

@implementation VDFLogUtility

+ (void)initialize {
    if (self == [VDFLogUtility self]) {
        g_loggers = [[NSMutableArray alloc] init];
    }
}

+ (void)logType:(VDFLogMessageType)logType message:(NSString*)format, ... {
    va_list arguments;
    va_start(arguments, format);
    
    // composing log message:
    NSMutableString *logMessage = [[NSMutableString alloc] init];
    
//    if(g_verboseLevel & VODLogInfoVerboseLevelLastCallStackEntry) {
//        NSArray *callstack = [NSThread callStackSymbols];
//        if([callstack count] > 1) {
//            [logMessage appendFormat:@"%@ ", [callstack objectAtIndex:1]];
//        }
//    }
//    
//    if(g_verboseLevel != VODLogInfoVerboseLevelBasic) {
//        [logMessage appendString:@"\n"];
//    }
    
    [logMessage appendString:[[NSString alloc] initWithFormat:format arguments:arguments]];
    
    for (id<VDFMessageLogger> logger in g_loggers) {
        [logger logMessage:logMessage ofType:logType];
    }
}

+ (void)subscribeLogger:(id<VDFMessageLogger>)logger {
    [g_loggers addObject:logger];
}

+ (void)unsubscribeLogger:(id<VDFMessageLogger>)logger {
    [g_loggers removeObject:logger];
}

@end

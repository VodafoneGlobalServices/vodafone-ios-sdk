//
//  VDFLogUtility.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 31/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFLogUtility.h"

static VODLogInfoVerboseLevel g_verboseLevel = VODLogInfoVerboseLevelBasic;

@implementation VDFLogUtility

+ (void)setVerboseLevel:(VODLogInfoVerboseLevel)level {
    g_verboseLevel = level;
}

+ (void)dLog:(NSString*)format, ...
{
    va_list arguments;
    va_start(arguments, format);
    
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    // 1   UIKit                               0x0253c32a -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 167
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" []?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    // composing log message:
    NSMutableString *logMessage = [[NSMutableString alloc] init];
    
    // caller memory address:
    if(g_verboseLevel & VODLogInfoVerboseLevelCallerMemoryAddress) {
        [logMessage appendFormat:@"%@ ", [array objectAtIndex:2]];
    }
    
    // caller class and method name:
    if(g_verboseLevel & (VODLogInfoVerboseLevelCallerClassName|VODLogInfoVerboseLevelCallerMethodName)) {
        // appending also method access modifier:
        [logMessage appendFormat:@"%@[", [array objectAtIndex:3]];
        
        // class name:
        if(g_verboseLevel & VODLogInfoVerboseLevelCallerClassName) {
            [logMessage appendFormat:@"%@", [array objectAtIndex:4]];
        }
        // method name:
        if(g_verboseLevel & VODLogInfoVerboseLevelCallerMethodName) {
            [logMessage appendFormat:@" %@", [array objectAtIndex:5]];
        }
        
        [logMessage appendString:@"] "];
    }
    
    // caller line number:
    if(g_verboseLevel & VODLogInfoVerboseLevelCallerLineNumber) {
        [logMessage appendFormat:@"+ %@ ", [array objectAtIndex:7]];
    }
    
    if(g_verboseLevel != VODLogInfoVerboseLevelBasic) {
        [logMessage appendString:@"\n"];
    }
    
    [logMessage appendString:[[NSString alloc] initWithFormat:format arguments:arguments]];
    NSLog(@"%@", logMessage);
}

@end

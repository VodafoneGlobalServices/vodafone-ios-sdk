//
//  VDFErrorUtility.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFErrorUtility.h"
#import "VDFLogUtility.h"

@implementation VDFErrorUtility

+ (BOOL)handleInternalError:(NSError*)error {
    if(error) {
        VDFLogD(@"Error occured: %@", error);
        return YES;
    }
    return NO;
}

@end

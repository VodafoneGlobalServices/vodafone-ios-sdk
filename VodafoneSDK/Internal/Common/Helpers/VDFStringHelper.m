//
//  VDFStringHelper.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFStringHelper.h"

@implementation VDFStringHelper

+ (NSString*)urlEncode:(NSString*)str
{
    NSString * encodedString =
    (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)str, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
    return encodedString;
}

@end

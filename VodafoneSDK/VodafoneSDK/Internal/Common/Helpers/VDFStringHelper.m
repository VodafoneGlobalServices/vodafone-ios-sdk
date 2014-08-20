//
//  VDFStringHelper.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFStringHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation VDFStringHelper

+ (NSString*)urlEncode:(NSString*)str
{
    NSString * encodedString =
    (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)str, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
    return encodedString;
}

+ (NSString*)md5FromString:(NSString*)string {
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString*)md5FromData:(NSData*)data {
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( data.bytes, data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

+ (NSString*)randomString {
    return [VDFStringHelper md5FromString:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
}

@end

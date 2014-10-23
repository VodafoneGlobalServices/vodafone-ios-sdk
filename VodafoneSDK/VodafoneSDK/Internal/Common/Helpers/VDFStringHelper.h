//
//  VDFStringHelper.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Helper class for NSString objects
 */
@interface VDFStringHelper : NSObject

/*!
 @abstract
 Encode string to url encoded format
 
 @return - Encoded string
 */
+ (NSString*)urlEncode:(NSString*)str;

/*!
 @abstract
 Generate md5 hash from string
 
 @return - Encoded string
 */
+ (NSString*)md5FromString:(NSString*)string;

/*!
 @abstract
 Generate md5 hash from contents of NSData object
 
 @return - Encoded string
 */
+ (NSString*)md5FromData:(NSData*)data;

/**
 *  Generates random string.
 *
 *  @return NSString generated randomly.
 */
+ (NSString*)randomString;

/**
 *  Validates string with regular expression.
 *
 *  @param stringToCheck String to validate.
 *  @param regexString   Regular expression of string validation.
 *
 *  @return YES - if string pass regular expression validation, NO - if string not pass regular expression check.
 */
+ (BOOL)isStringValid:(NSString*)stringToCheck withRegularExpression:(NSString*)regexString;

@end

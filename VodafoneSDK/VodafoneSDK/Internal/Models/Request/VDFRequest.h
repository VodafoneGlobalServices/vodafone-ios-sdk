//
//  VDFRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFEnums.h"

/**
 *  Internal SDK request protocol
 */
@protocol VDFRequest <NSObject>

/**
 *  Address of the web resource of request.
 *
 *  @return URL query string.
 */
- (NSString*)urlEndpointMethod;

/**
 *  Expiration date of requests results.
 *
 *  @return Date object.
 */
- (NSDate*)expirationDate;

/*!
 @abstract
    Parsing NSData object representing JSON string. It not invoking delegate methods. Updates state of the request. Can change the session token of the request.
 
 @param data - NSData object repesenting JSON string to parse.
 
 @return Parsed object or nil (when parsing error occured). It need to be passed to onObjectResponse: method to inform delegate object.
 */
- (id<NSCoding>)parseAndUpdateOnDataResponse:(NSData*)data;

/*!
 @abstract
    Inform delegate about received response object. It invoke delegate methods. Updates state of the request. Can change the session token of the request.
 
 @param parsedObject - Parsed response object.
 @param error - Error object if is any.
 */
- (void)onObjectResponse:(id<NSCoding>)parsedObject withError:(NSError*)error;

/**
 *  Verifies equality of two requests.
 *
 *  @param request Request object to comapre.
 *
 *  @return YES - if equals, NO - if not
 */
- (BOOL)isEqualToRequest:(id<VDFRequest>)request;

/**
 *  Checks is specified delegate is the one from parameter then remove it from request.
 *
 *  @param delegate Delegate object which need to be unsubscribed from request.
 */
- (void)clearDelegateIfEquals:(id)delegate;

/**
 *  Checks is there still some delegate waiting for requests.
 *
 *  @return YES - if there is still one, NO - if there are no waiting delegates
 */
- (BOOL)isDelegateAvailable;

@optional

/*!
 @abstract
    Invoked only when request needs connection to the server. Provide information about response code of http connection.
    Is called before parseAndUpdateOnDataResponse and onObjectResponse methods.
 
 @param responseCode - HTTP response code
 */
- (void)onHttpResponseCode:(NSInteger)responseCode;

/**
 *  Http operatiom method type.
 *  Default GET.
 *
 *  @return Method type enum.
 */
- (HTTPMethodType)httpMethod;

/**
 *  Payload of POST message body.
 *
 *  @return NSData object with payload used in http request.
 */
- (NSData*)postBody;

/**
 *  Indicates is request need to retry te request to the server because the response state is not satisfied.
 *  Default return YES
 *
 *  @return YES - when not need to retry the http request, NO - when need to retry.
 */
- (BOOL)isSatisfied;

/**
 *  Indicates is response of this request need to be cached
 *  Default NO.
 *
 *  @return YES - when response schould be cached, NO - when response schould not be cached.
 */
- (BOOL)isCachable;

/**
 *  Indicates is http request need GSM connection.
 *  Default NO
 *
 *  @return YES - when http request need GSM for connection, NO - when is not required.
 */
- (BOOL)isGSMConnectionRequired;

#pragma mark - implemented in VDFBaseRequest

/**
 *  Generates MD5 hash from request.
 *
 *  @return String representing md5 hash.
 */
- (NSString*)md5Hash;

@end

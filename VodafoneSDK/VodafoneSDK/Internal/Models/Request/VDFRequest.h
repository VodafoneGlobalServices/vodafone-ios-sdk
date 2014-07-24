//
//  VDFRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFEnums.h"

@protocol VDFRequest <NSObject>

- (NSString*)urlEndpointMethod;

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

- (BOOL)isEqualToRequest:(id<VDFRequest>)request;

- (void)clearDelegateIfEquals:(id)delegate;

- (BOOL)isDelegateAvailable;

@optional

/*!
 @abstract
    Invoked only when request needs connection to the server. Provide information about response code of http connection.
    Is called before parseAndUpdateOnDataResponse and onObjectResponse methods.
 
 @param responseCode - HTTP response code
 */
- (void)onHttpResponseCode:(NSInteger)responseCode;

// POST or GET
// default GET
- (HTTPMethodType)httpMethod;

- (NSData*)postBody;

// default YES
- (BOOL)isSatisfied;

// defualt NO
- (BOOL)isCachable;

#pragma mark - implemented in VDFBaseRequest
- (NSString*)md5Hash;
@end

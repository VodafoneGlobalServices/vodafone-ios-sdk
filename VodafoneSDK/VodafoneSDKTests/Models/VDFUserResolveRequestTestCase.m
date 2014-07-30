//
//  VDFUserResolveRequestTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 24/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFUserResolveRequest.h"
//#import <OCMock/OCMock.h>
//#import "OCMock.h"
//#import "OCMockObject.h"

/*
 
 @protocol VDFRequest <NSObject>
 
 - (NSString*)urlEndpointMethod;
 
 - (NSDate*)expirationDate;
 

 @abstract
 Parsing NSData object representing JSON string. It not invoking delegate methods. Updates state of the request. Can change the session token of the request.
 
 @param data - NSData object repesenting JSON string to parse.
 
 @return Parsed object or nil (when parsing error occured). It need to be passed to onObjectResponse: method to inform delegate object.

- (id<NSCoding>)parseAndUpdateOnDataResponse:(NSData*)data;


 @abstract
 Inform delegate about received response object. It invoke delegate methods. Updates state of the request. Can change the session token of the request.
 
 @param parsedObject - Parsed response object.
 @param error - Error object if is any.

- (void)onObjectResponse:(id<NSCoding>)parsedObject withError:(NSError*)error;

- (BOOL)isEqualToRequest:(id<VDFRequest>)request;

- (void)clearDelegateIfEquals:(id)delegate;

- (BOOL)isDelegateAvailable;

@optional


 @abstract
 Invoked only when request needs connection to the server. Provide information about response code of http connection.
 Is called before parseAndUpdateOnDataResponse and onObjectResponse methods.
 
 @param responseCode - HTTP response code

- (void)onHttpResponseCode:(NSInteger)responseCode;

// POST or GET
// default GET
- (HTTPMethodType)httpMethod;

- (NSData*)postBody;

// default YES
- (BOOL)isSatisfied;

// default NO
- (BOOL)isCachable;

// default NO
- (BOOL)isGSMConnectionRequired;

#pragma mark - implemented in VDFBaseRequest
- (NSString*)md5Hash;
@end


 */

@interface VDFUserResolveRequest (Tests)
@property (nonatomic, assign) id<VDFUsersServiceDelegate> delegate;
@property (nonatomic, strong) VDFUserResolveOptions *requestOptions;
@property (nonatomic, strong) NSString *applicationId;

- (void)updateRequestState:(VDFUserTokenDetails*)details;
@end

@interface VDFUserResolveRequestTestCase : XCTestCase

@end

@implementation VDFUserResolveRequestTestCase

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    VDFUserResolveRequest *toTest = [[VDFUserResolveRequest alloc] initWithApplicationId:@"" withOptions:nil delegate:nil];
    
//    id mockRequestToTest = [OCMockObject partialMockForObject:toTest];
    
    
}

@end

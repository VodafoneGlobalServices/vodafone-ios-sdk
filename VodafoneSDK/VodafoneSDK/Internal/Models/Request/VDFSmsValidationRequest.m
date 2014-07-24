//
//  VDFSmsValidationRequest.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 23/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationRequest.h"
#import "VDFErrorUtility.h"
#import "VDFStringHelper.h"
#import "VDFError.h"

static NSString * const URLEndpointQuery = @"/users/tokens/validate/";
static NSString * const JSONPayloadBodyFormat = @"{ \"code\" : \"%@\" }";
static NSInteger const SuccessfulResponseCode = 200;
static NSInteger const FailureResponseCode = 400;

@interface VDFSmsValidationRequest ()
@property (nonatomic, assign) id<VDFUsersServiceDelegate> delegate;
@property (nonatomic, strong) NSString *applicationId;
@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) NSString *smsCode;
@property (nonatomic, assign) NSInteger responseCode;
@end

@implementation VDFSmsValidationRequest

- (instancetype)initWithApplicationId:(NSString*)applicationId sessionToken:(NSString*)sessionToken smsCode:(NSString*)smsCode delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        self.applicationId = applicationId;
        self.sessionToken = sessionToken;
        self.smsCode = smsCode;
        self.satisfied = NO;
    }
    return self;
}

#pragma mark -
#pragma mark VDFRequest Implementation

- (id<NSCoding>)parseAndUpdateOnDataResponse:(NSData*)data {
    
    if(self.responseCode == SuccessfulResponseCode) {
        // on success we do not need to parse response
    }
    else if(self.responseCode == FailureResponseCode) {
        // in case of failure we can read the status and errorMessage
        // but for what ?
    }
    
    // TODO think about this
    
    return nil;
}

- (void)onObjectResponse:(id<NSCoding>)parsedObject withError:(NSError*)error {
    if(self.delegate != nil) {
        [self.delegate didValidatedSMSToken:self.smsCode success:self.responseCode == SuccessfulResponseCode withError:error];
    }
}

- (void)onHttpResponseCode:(NSInteger)responseCode {
    self.responseCode = responseCode;
}

- (NSString*)urlEndpointMethod {
    return [URLEndpointQuery stringByAppendingString:self.sessionToken];
}

- (NSDate*)expirationDate {
    return [NSDate date];// this is not cached so it expires immediately
}

- (void)clearDelegateIfEquals:(id)delegate {
    if(delegate == self.delegate) {
        self.delegate = nil;
    }
}

- (BOOL)isDelegateAvailable {
    return self.delegate != nil;
}

- (HTTPMethodType)httpMethod {
    return HTTPMethodPOST;
}

- (NSData*)postBody {
    // faster and sipler will be to format the string
    return [[NSString stringWithFormat:JSONPayloadBodyFormat, [VDFStringHelper urlEncode:self.smsCode]] dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)isEqualToRequest:(id<VDFRequest>)request {
    if(request == nil) {
        return NO;
    }
    
    VDFSmsValidationRequest * smsValidationRequest = (VDFSmsValidationRequest*)request;
    if(![self.applicationId isEqualToString:smsValidationRequest.applicationId]) {
        return NO;
    }
    if(![self.sessionToken isEqualToString:smsValidationRequest.sessionToken]) {
        return NO;
    }
    
    return [self.smsCode isEqualToString:smsValidationRequest.smsCode];
}

@end

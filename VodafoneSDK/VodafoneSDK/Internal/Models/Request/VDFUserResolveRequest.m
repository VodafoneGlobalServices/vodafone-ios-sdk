//
//  VDFUserResolveRequest.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveRequest.h"
#import "VDFUserResolveOptions.h"
#import "VDFErrorUtility.h"
#import "VDFUserTokenDetails.h"
#import "VDFStringHelper.h"
#import "VDFError.h"

static NSString * const URLEndpointQuery = @"/users/resolve";

@interface VDFUserResolveRequest ()
@property (nonatomic, assign) id<VDFUsersServiceDelegate> delegate;
@property (nonatomic, strong) VDFUserResolveOptions *requestOptions;
@property (nonatomic, strong) NSString *applicationId;

- (void)updateRequestState:(VDFUserTokenDetails*)details;
@end

@implementation VDFUserResolveRequest

- (instancetype)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        self.requestOptions = [options copy]; // we need to copy this options because if the session token will change we need to update it
        self.applicationId = applicationId;
        self.satisfied = NO;
    }
    return self;
}

#pragma mark -
#pragma mark private methods implementation

- (void)updateRequestState:(VDFUserTokenDetails*)details {
    if(!self.satisfied) {
        self.satisfied = !details.stillRunning;
    }
    self.expiresIn = details.expires;
    if(details.token != nil) {
        self.requestOptions.token = details.token;
    }
}

#pragma mark -
#pragma mark VDFRequest Implementation

- (id<NSCoding>)parseAndUpdateOnDataResponse:(NSData*)data {
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
    VDFUserTokenDetails* userTokenDetails = nil;
    
    if([VDFErrorUtility handleInternalError:error] || !isResponseValid) {
        // handle error here
        // TODO
    }
    else {
        // object parsed correctlly
        userTokenDetails = [[VDFUserTokenDetails alloc] initWithJsonObject:jsonObject];
        // need to update request state:
        [self updateRequestState:userTokenDetails];
    }
    return userTokenDetails;
}

- (void)onObjectResponse:(id<NSCoding>)parsedObject withError:(NSError*)error {
    if(parsedObject == nil && error == nil) {
        // parse error occured:
        error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorServerCommunication userInfo:nil];
    }
    VDFUserTokenDetails * userTokenDetails = (VDFUserTokenDetails*)parsedObject;
    
    // need to update request state:
    if(userTokenDetails != nil) {
        [self updateRequestState:userTokenDetails];
    }
    
    if(self.delegate != nil) {
        // invoke delegate with response on the main thread:
        if([NSThread isMainThread]) {
            [self.delegate didReceivedUserDetails:userTokenDetails withError:error];
        }
        else {
            // we are on some different thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didReceivedUserDetails:userTokenDetails withError:error];
            });
        }
    }

}

- (NSString*)urlEndpointMethod {
    return URLEndpointQuery;
}

- (NSDate*)expirationDate {
    if(self.expiresIn == nil) {
        self.expiresIn = [NSDate dateWithTimeIntervalSinceNow:3600*24]; // default one day - TODO move to the configuration
    }
    return self.expiresIn;
}

- (void)clearDelegateIfEquals:(id)delegate {
    if(delegate == self.delegate) {
        self.delegate = nil;
    } // TODO think, how to move to base object
}

- (BOOL)isDelegateAvailable {
    return self.delegate != nil;
}

- (HTTPMethodType)httpMethod {
    return HTTPMethodPOST;
}

- (BOOL)isCachable {
    return YES;
}

- (NSData*)postBody {
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:[VDFStringHelper urlEncode:self.applicationId] forKey:@"applicationId"];
    if(self.requestOptions.token) {
        [jsonDictionary setObject:[VDFStringHelper urlEncode:self.requestOptions.token] forKey:@"sessionToken"];
    }
    if(self.requestOptions.validateWithSms) {
        [jsonDictionary setObject:@"true" forKey:@"smsValidation"];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    if([VDFErrorUtility handleInternalError:error]) {
        // handle error here
        // TODO
        jsonData = nil;
    }
    return jsonData;
}

- (BOOL)isEqualToRequest:(id<VDFRequest>)request {
    if(request == nil) {
        return NO;
    }
    
    VDFUserResolveRequest * userResolveRequest = (VDFUserResolveRequest*)request;
    if(![self.applicationId isEqualToString:userResolveRequest.applicationId]) {
        return NO;
    }
    
    return [self.requestOptions isEqualToOptions:userResolveRequest.requestOptions];
}

@end

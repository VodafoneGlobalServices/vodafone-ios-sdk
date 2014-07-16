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

static NSString * const URLEndpointQuery = @"/users/resolve";

@interface VDFUserResolveRequest ()
@property (nonatomic, assign) id<VDFUsersServiceDelegate> delegate;
@property (nonatomic, strong) VDFUserResolveOptions* requestOptions;
@property (nonatomic, strong) NSString* applicationId;
@property (nonatomic, assign) BOOL satisfied;

- (void)updateSatisfiedFlagWith:(VDFUserTokenDetails*)details;
@end

@implementation VDFUserResolveRequest

- (id)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        self.requestOptions = options;
        self.applicationId = applicationId;
        self.satisfied = NO;
    }
    return self;
}

#pragma mark -
#pragma mark NSCopying implementation
- (id)copyWithZone:(NSZone *)zone {
    return nil; // TODO
}

#pragma mark -
#pragma mark private methods implementation

- (void)updateSatisfiedFlagWith:(VDFUserTokenDetails*)details {
    if(!self.satisfied) {
        self.satisfied = !details.stillRunning;
    }
}

#pragma mark -
#pragma mark VDFRequest Implementation

- (NSString*)urlEndpointMethod {
    return URLEndpointQuery;
}

- (void)onDataResponse:(NSData*)data {
    // response parse and pass to delegate:
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options: kNilOptions error: &error];
    BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
    VDFUserTokenDetails* userDetails = nil;
    
    if([VDFErrorUtility handleInternalError:error] || !isResponseValid) {
        // handle error here
        // TODO
    }
    else {
        error = nil;
        // object parsed correctlly
        userDetails = [[VDFUserTokenDetails alloc] initWithJsonObject:jsonObject];
        [self updateSatisfiedFlagWith:userDetails];
        // TODO check is delegate in the same thread:
    }
    
    // sending response to delegate:
    [self.delegate didReceivedUserDetails:userDetails withError:error];
}

- (NSTimeInterval)defaultCacheTime {
    return 3600*24; // one day
}

- (NSString*)httpMethod {
    return @"POST";
}

- (NSDictionary*)postParameters {
    NSMutableDictionary *parametersDictionary = [[NSMutableDictionary alloc] init];
    [parametersDictionary setObject:self.applicationId forKey:@"applicationId"];
    if(self.sessionToken) {
        [parametersDictionary setObject:self.sessionToken forKey:@"sessionToken"];
    }
    if(self.requestOptions.validateWithSms) {
        [parametersDictionary setObject:@"true" forKey:@"smsValidation"];
    }
    return parametersDictionary;
}

- (BOOL)isSimultenaous {
    return YES;
}

- (BOOL)isSatisfied {
    return self.satisfied;
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

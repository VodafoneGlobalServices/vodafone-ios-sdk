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

- (VDFUserTokenDetails*)parseJsonData:(NSData*)jsonData error:(NSError**)error {
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:error];
    BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
    VDFUserTokenDetails* userDetails = nil;
    
    if([VDFErrorUtility handleInternalError:*error] || !isResponseValid) {
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
    return userDetails;
}

#pragma mark -
#pragma mark - Base Methods Override
- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    result = prime * result + [self.applicationId hash];
    result = prime * result + [self.requestOptions hash];
    
    return result;
}

- (BOOL)isEqual:(id)anObject {
    if (![anObject isKindOfClass:[VDFUserResolveRequest class]]) {
        return NO;
    }
    
    return [self isEqualToRequest:(VDFUserResolveRequest *)anObject];
}

#pragma mark -
#pragma mark NSCopying implementation
- (id)copyWithZone:(NSZone *)zone {
    VDFUserResolveRequest *newRequest = [[VDFUserResolveRequest allocWithZone:zone] init];
    newRequest.delegate = self.delegate;
    newRequest.requestOptions = [self.requestOptions copyWithZone:zone];
    newRequest.applicationId = [self.applicationId copyWithZone:zone];
    newRequest.satisfied = self.satisfied;
    newRequest.sessionToken = [self.sessionToken copyWithZone:zone];
    return newRequest;
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
    NSError *error = nil;
    VDFUserTokenDetails *userDetails = [self parseJsonData:data error:&error];
    // sending response to delegate:
    [self.delegate didReceivedUserDetails:userDetails withError:error];
}

- (NSTimeInterval)defaultCacheTime {
    return 3600*24; // one day
}

- (NSString*)httpMethod {
    return @"POST";
}

- (NSData*)postBody {
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:[VDFStringHelper urlEncode:self.applicationId] forKey:@"applicationId"];
    if(self.sessionToken) {
        [jsonDictionary setObject:[VDFStringHelper urlEncode:self.sessionToken] forKey:@"sessionToken"];
    }
    if(self.requestOptions.validateWithSms) {
        [jsonDictionary setObject:@"true" forKey:@"smsValidation"];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options: NSJSONWritingPrettyPrinted error:&error];
    
    if([VDFErrorUtility handleInternalError:error]) {
        // handle error here
        // TODO
        jsonData = nil;
    }
    return jsonData;
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

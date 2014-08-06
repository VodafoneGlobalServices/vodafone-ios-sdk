//
//  VDFUserResolveRequestFactory.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveRequestFactory.h"
#import "VDFUserResolveRequestState.h"
#import "VDFUserResolveResponseParser.h"
#import "VDFCacheObject.h"
#import "VDFHttpConnector.h"
#import "VDFUserResolveOptions.h"
#import "VDFEnums.h"
#import "VDFStringHelper.h"
#import "VDFErrorUtility.h"
#import "VDFBaseConfiguration.h"
#import "VDFUserResolveRequestBuilder.h"
#import "VDFUsersServiceDelegate.h"

@interface VDFUserResolveRequestFactory ()
@property (nonatomic, strong) VDFUserResolveRequestBuilder *builder;

- (NSData*)postBody;
@end

@implementation VDFUserResolveRequestFactory

- (instancetype)initWithBuilder:(VDFUserResolveRequestBuilder*)builder {
    self = [super init];
    if(self) {
        self.builder = builder;
    }
    return self;
}

- (NSData*)postBody {
    NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:[VDFStringHelper urlEncode:self.builder.applicationId] forKey:@"applicationId"];
    if(self.builder.requestOptions.token) {
        [jsonDictionary setObject:[VDFStringHelper urlEncode:self.builder.requestOptions.token] forKey:@"sessionToken"];
    }
    if(self.builder.requestOptions.validateWithSms) {
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

#pragma mark -
#pragma mark VDFRequestFactory implementation

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    
    NSString * requestUrl = [self.builder.configuration.endpointBaseUrl stringByAppendingString:self.builder.urlEndpointQuery];
    
    VDFHttpConnector * httpRequest = [[VDFHttpConnector alloc] initWithDelegate:delegate];
    httpRequest.connectionTimeout = self.builder.configuration.defaultHttpConnectionTimeout;
    httpRequest.methodType = self.builder.httpRequestMethodType;
    httpRequest.postBody = [self postBody];
    httpRequest.url = requestUrl;
//    httpRequest.isGSMConnectionRequired = YES; // TODO !!! uncomment this // commented only for test purposes
    
    return httpRequest;
}

- (VDFCacheObject*)createCacheObject {
    NSString *stringToHash = [NSString stringWithFormat:@"%@%ul%@", self.builder.urlEndpointQuery, self.builder.httpRequestMethodType, [VDFStringHelper md5FromData:[self postBody]]];
    NSString *md5Hash = [VDFStringHelper md5FromString:stringToHash];
    
    id<VDFRequestState> currentState = [self.builder requestState];
    
    return [[VDFCacheObject alloc] initWithValue:nil forKey:md5Hash withExpirationDate:[currentState lastResponseExpirationDate]];
}

- (id<VDFResponseParser>)createResponseParser {
    return [[VDFUserResolveResponseParser alloc] init];
}

- (id<VDFRequestState>)createRequestState {
    return [[VDFUserResolveRequestState alloc] initWithRequestOptionsReference:self.builder.requestOptions];
}

- (id<VDFObserversContainer>)createObserversContainer {
    id<VDFObserversContainer> observersContainer = [super createObserversContainer];
    [observersContainer setObserversNotifySelector:@selector(didReceivedUserDetails:withError:)];
    return observersContainer;
}

@end

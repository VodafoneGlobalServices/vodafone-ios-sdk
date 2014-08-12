//
//  VDFSmsValidationRequestBuilder.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationRequestBuilder.h"
#import "VDFSmsValidationRequestFactory.h"

static NSString * const URLEndpointQuery = @"/users/tokens/validate/";
static NSString * const DESCRIPTION_FORMAT = @"VDFUserResolveRequestFactoryBuilder:\n\t urlEndpointMethod:%@ \n\t httpMethod:%@ \n\t applicationId:%@ \n\t sessionToke:%@ \n\t smsCode:%@ ";

@implementation VDFSmsValidationRequestBuilder

- (instancetype)initWithApplicationId:(NSString*)applicationId sessionToken:(NSString*)sessionToken smsCode:(NSString*)smsCode withConfiguration:(VDFBaseConfiguration*)configuration delegate:(id<VDFUsersServiceDelegate>)delegate {
    self = [super initWithFactory:[[VDFSmsValidationRequestFactory alloc] initWithBuilder:self] applicationId:applicationId configuration:configuration];
    if(self) {
        _urlEndpointQuery = [URLEndpointQuery stringByAppendingString:sessionToken];
        _httpRequestMethodType = HTTPMethodPOST;
        self.sessionToken = sessionToken;
        self.smsCode = smsCode;
        
        if(delegate != nil) {
            [[self observersContainer] registerObserver:delegate];
        }
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, [self urlEndpointQuery], ([self httpRequestMethodType] == HTTPMethodGET) ? @"GET":@"POST", self.applicationId, self.sessionToken, self.smsCode];
}

#pragma mark -
#pragma mark VDFRequestFactoryBuilder Implementation

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    if(builder == nil || ![builder isKindOfClass:[VDFSmsValidationRequestBuilder class]]) {
        return NO;
    }
    
    VDFSmsValidationRequestBuilder * smsValidationBuilder = (VDFSmsValidationRequestBuilder*)builder;
    if(![self.applicationId isEqualToString:smsValidationBuilder.applicationId]) {
        return NO;
    }
    if(![self.sessionToken isEqualToString:smsValidationBuilder.sessionToken]) {
        return NO;
    }
    
    return [self.smsCode isEqualToString:smsValidationBuilder.smsCode];
}

@end

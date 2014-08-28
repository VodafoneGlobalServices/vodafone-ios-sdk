//
//  VDFUserResolveRequestFactoryBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFRequestBuilder.h"
#import "VDFEnums.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFRequestBaseBuilder.h"
#import "VDFOAuthTokenRequestDelegate.h"

@class VDFDIContainer, VDFUserResolveOptions, VDFOAuthTokenResponse;

@interface VDFUserResolveRequestBuilder : VDFRequestBaseBuilder <VDFOAuthTokenRequestDelegate>

// TODO documentation
@property (nonatomic, strong) VDFUserResolveOptions *requestOptions;
@property (nonatomic, readonly) NSString *initialUrlEndpointQuery;
@property (nonatomic, readonly) NSString *retryUrlEndpointQuery;
@property (nonatomic, readonly) HTTPMethodType httpRequestMethodType;
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;
@property (nonatomic, strong) NSString *eTag;
@property (nonatomic, strong) NSString *sessionToken;

- (instancetype)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

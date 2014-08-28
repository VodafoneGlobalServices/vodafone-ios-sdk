//
//  VDFSmsSendPinRequestBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseBuilder.h"
#import "VDFEnums.h"
#import "VDFOAuthTokenRequestDelegate.h"
#import "VDFUsersServiceDelegate.h"

@class VDFOAuthTokenResponse;

@interface VDFSmsSendPinRequestBuilder : VDFRequestBaseBuilder <VDFOAuthTokenRequestDelegate>

// TODO documentation
@property (nonatomic, copy) NSString *sessionToken;
@property (nonatomic, readonly) NSString *urlEndpointQuery;
@property (nonatomic, readonly) HTTPMethodType httpRequestMethodType;
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;

- (instancetype)initWithApplicationId:(NSString*)applicationId sessionToken:(NSString*)sessionToken diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate;
@end

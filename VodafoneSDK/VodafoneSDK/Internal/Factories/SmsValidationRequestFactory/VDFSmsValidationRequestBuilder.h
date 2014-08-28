//
//  VDFSmsValidationRequestBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseBuilder.h"
#import "VDFUsersServiceDelegate.h"
#import "VDFEnums.h"
#import "VDFOAuthTokenRequestDelegate.h"

@class VDFOAuthTokenResponse;

@interface VDFSmsValidationRequestBuilder : VDFRequestBaseBuilder <VDFOAuthTokenRequestDelegate>

// TODO documentation
@property (nonatomic, copy) NSString *sessionToken;
@property (nonatomic, copy) NSString *smsCode;
@property (nonatomic, readonly) NSString *urlEndpointQuery;
@property (nonatomic, readonly) HTTPMethodType httpRequestMethodType;
@property (nonatomic, strong) VDFOAuthTokenResponse *oAuthToken;

- (instancetype)initWithApplicationId:(NSString*)applicationId sessionToken:(NSString*)sessionToken smsCode:(NSString*)smsCode diContainer:(VDFDIContainer*)diContainer delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

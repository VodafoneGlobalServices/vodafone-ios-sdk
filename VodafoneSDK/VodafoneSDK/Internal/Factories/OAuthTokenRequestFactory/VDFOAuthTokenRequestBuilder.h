//
//  VDFOAuthTokenRequestBuilder.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseBuilder.h"
#import "VDFEnums.h"
#import "VDFOAuthTokenRequestDelegate.h"

@class VDFOAuthTokenRequestOptions;

@interface VDFOAuthTokenRequestBuilder : VDFRequestBaseBuilder

@property (nonatomic, strong) VDFOAuthTokenRequestOptions *requestOptions;
@property (nonatomic, readonly) NSString *urlEndpointQuery;
@property (nonatomic, readonly) HTTPMethodType httpRequestMethodType;

- (instancetype)initWithApplicationId:(NSString*)applicationId
                          withOptions:(VDFOAuthTokenRequestOptions*)options
                    withConfiguration:(VDFBaseConfiguration*)configuration
                             delegate:(id<VDFOAuthTokenRequestDelegate>)delegate;

@end

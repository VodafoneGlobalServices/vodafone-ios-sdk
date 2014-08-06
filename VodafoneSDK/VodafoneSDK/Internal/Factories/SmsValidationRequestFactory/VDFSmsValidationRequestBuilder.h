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

@interface VDFSmsValidationRequestBuilder : VDFRequestBaseBuilder

// TODO documentation
@property (nonatomic, copy) NSString *sessionToken;
@property (nonatomic, copy) NSString *smsCode;
@property (nonatomic, readonly) NSString *urlEndpointQuery;
@property (nonatomic, readonly) HTTPMethodType httpRequestMethodType;

- (instancetype)initWithApplicationId:(NSString*)applicationId sessionToken:(NSString*)sessionToken smsCode:(NSString*)smsCode withConfiguration:(VDFBaseConfiguration*)configuration delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

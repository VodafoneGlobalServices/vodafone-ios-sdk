//
//  VDFSmsValidationRequest.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 23/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersServiceDelegate.h"
#import "VDFRequest.h"
#import "VDFBaseRequest.h"

@interface VDFSmsValidationRequest : VDFBaseRequest

- (instancetype)initWithApplicationId:(NSString*)applicationId sessionToken:(NSString*)sessionToken smsCode:(NSString*)smsCode delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

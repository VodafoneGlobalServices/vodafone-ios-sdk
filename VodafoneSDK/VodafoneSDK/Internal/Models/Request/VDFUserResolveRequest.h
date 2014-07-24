//
//  VDFUserResolveRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersServiceDelegate.h"
#import "VDFRequest.h"
#import "VDFBaseRequest.h"

@class VDFUserResolveOptions, VDFUserTokenDetails;

@interface VDFUserResolveRequest : VDFBaseRequest

- (instancetype)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

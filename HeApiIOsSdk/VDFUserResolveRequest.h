//
//  VDFUserResolveRequest.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersServiceDelegate.h"
#import "VDFRequest.h"

@class VDFUserResolveOptions;

@interface VDFUserResolveRequest : NSObject <VDFRequest>

@property (nonatomic, strong) NSString* sessionToken;

- (id)initWithApplicationId:(NSString*)applicationId withOptions:(VDFUserResolveOptions*)options delegate:(id<VDFUsersServiceDelegate>)delegate;

@end

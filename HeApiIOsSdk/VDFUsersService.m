//
//  VDFUsersService.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 07/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersService.h"
#import "VDFUserTokenDetails.h"
#import "VDFUserResolveOptions.h"

@implementation VDFUsersService

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void)retrieveUserDetails:(VDFUserResolveOptions *)options delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // create request object
    // over some factory
    
    // get http request manager
    // perform request call
    
}

- (VDFUserTokenDetails*)getUserDetails:(VDFUserResolveOptions*)options {
    
    // get cache manager
    // check cache and return value
}

- (void)validateSMSToken:(NSString*)smsCode delegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // create request object
    // over some factory
    
    // get http request manager
    // perform request call
}

- (void)removeDelegate:(id<VDFUsersServiceDelegate>)delegate {
    
    // get http request manager
    // inform about request remove
}

@end

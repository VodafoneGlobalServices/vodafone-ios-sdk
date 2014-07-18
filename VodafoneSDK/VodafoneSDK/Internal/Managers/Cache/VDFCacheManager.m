//
//  VDFCacheManager.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFCacheManager.h"
#import "VDFBaseConfiguration.h"

@interface VDFCacheManager ()
@property (nonatomic, strong) VDFBaseConfiguration * configuration;
@end


@implementation VDFCacheManager

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        self.configuration = configuration;
    }
    return self;
}

- (BOOL)isResponseCachedForRequest:(id<VDFRequest>)request {
    return NO; // TODO
}

- (NSData*)responseForRequest:(id<VDFRequest>)request {
    return nil; // TODO
}

- (void)cacheResponseData:(NSData*)responseData forRequest:(id<VDFRequest>)request {
    // TODO
}


@end

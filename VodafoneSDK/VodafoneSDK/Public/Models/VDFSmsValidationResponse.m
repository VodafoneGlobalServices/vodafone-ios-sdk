//
//  VDFSmsValidationResponse.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 06/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsValidationResponse.h"

@implementation VDFSmsValidationResponse

- (instancetype)initWithSmsCode:(NSString*)code isSucceded:(BOOL)isSucceded {
    self = [super init];
    if(self) {
        _isSucceded = isSucceded;
        _smsCode = [code copy];
    }
    return self;
}

#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    return [super init];
    // this class is no cached so it do not need to implement NSCoding properly
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    // this class is no cached so it do not need to implement NSCoding properly
}

@end

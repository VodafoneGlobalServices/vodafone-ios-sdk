//
//  VDFValidatePinObserversContainer.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 15/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFValidatePinObserversContainer.h"
#import "VDFSmsValidationResponse.h"

@interface VDFValidatePinObserversContainer ()
@property (nonatomic, strong) NSString* smsCode;
@end

@implementation VDFValidatePinObserversContainer

- (instancetype)initWithSmsCode:(NSString*)smsCode {
    self = [super init];
    if(self) {
        self.smsCode = smsCode;
    }
    return self;
}

- (void)notifyAllObserversWith:(id)object error:(NSError*)error {
    if(error != nil) {
        // when some error occure then result is always set to object
        VDFSmsValidationResponse *response = [[VDFSmsValidationResponse alloc] initWithSmsCode:self.smsCode isSucceded:NO];
        [super notifyAllObserversWith:response error:error];
    }
    else {
        [super notifyAllObserversWith:object error:error];
    }
}
@end

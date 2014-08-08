//
//  VDFUsersServiceDelegateCallCounterMock.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 07/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUsersServiceDelegateMock.h"

@implementation VDFUserDetailsResponseMock
@end

@implementation VDFSmsValidationResponseMock
@end

@interface VDFUsersServiceDelegateMock ()
@property NSMutableArray *internalUserDetails;
@property NSMutableArray *internalSmsValidations;
@end

@implementation VDFUsersServiceDelegateMock

- (instancetype)init {
    self = [super init];
    if(self) {
        self.internalUserDetails = [[NSMutableArray alloc] init];
        self.internalSmsValidations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray*)userDetailsResponses {
    return self.internalUserDetails;
}

- (NSArray*)smsValdiationsResponses {
    return self.internalSmsValidations;
}

-(void)didReceivedUserDetails:(VDFUserTokenDetails*)userDetails withError:(NSError*)error {
    VDFUserDetailsResponseMock *mock = [[VDFUserDetailsResponseMock alloc] init];
    mock.response = userDetails;
    mock.error = error;
    [self.internalUserDetails addObject:mock];
}

- (void)didValidatedSMSToken:(VDFSmsValidationResponse*)response withError:(NSError*)error {
    VDFSmsValidationResponseMock *mock = [[VDFSmsValidationResponseMock alloc] init];
    mock.response = response;
    mock.error = error;
    [self.internalSmsValidations addObject:mock];
}

@end

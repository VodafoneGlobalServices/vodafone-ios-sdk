//
//  VDFUsersServiceDelegateCallCounterMock.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 07/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDFUsersServiceDelegate.h"
#import "VDFUserTokenDetails.h"
#import "VDFSmsValidationResponse.h"

@interface VDFUserDetailsResponseMock : NSObject
@property (nonatomic, strong) VDFUserTokenDetails *response;
@property (nonatomic, strong) NSError *error;
@end

@interface VDFSmsValidationResponseMock : NSObject
@property (nonatomic, strong) VDFSmsValidationResponse *response;
@property (nonatomic, strong) NSError *error;
@end

@interface VDFUsersServiceDelegateMock : NSObject <VDFUsersServiceDelegate>

@property (nonatomic, readonly) NSArray *userDetailsResponses;
@property (nonatomic, readonly) NSArray *smsValdiationsResponses;

@end

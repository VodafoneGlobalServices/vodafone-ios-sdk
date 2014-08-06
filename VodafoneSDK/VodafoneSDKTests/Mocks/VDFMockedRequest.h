//
//  VDFMockedRequest.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 01/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseRequest.h"

@interface VDFMockedRequest : VDFBaseRequest

@property NSString *mockMd5Hash;
@property NSString *mockUrlEndpointMethod;
@property NSDate *mockExpirationDate;
@property BOOL mockIsSatisified;
@property BOOL mockIsCachable;
@property BOOL mockIsGSMConnectionRequired;
@property id mockDelegate;
@property HTTPMethodType mockHttpMethod;
@property NSData *mockPostBody;

@end

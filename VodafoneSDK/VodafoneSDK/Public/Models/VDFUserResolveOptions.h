//
//  VDFUserResolveOptions.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @class VDFUserResolveOptions
 
 @abstract
    Representation of arguments passed to the getUserDetails: method of VDFUsersService class.
 */
@interface VDFUserResolveOptions : NSObject <NSCopying>

/*! @abstract If set to YES, the server will send an SMS with code. */
@property (nonatomic, assign) BOOL validateWithSms;

- (instancetype)initWithValidateWithSms:(BOOL)validateWithSms;

- (BOOL)isEqualToOptions:(VDFUserResolveOptions*)options;

@end

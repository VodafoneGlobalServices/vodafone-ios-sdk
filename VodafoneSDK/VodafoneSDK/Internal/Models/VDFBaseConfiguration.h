//
//  VDFBaseConfiguration.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFBaseConfiguration : NSObject

@property (nonatomic, copy) NSString *applicationId;

@property (nonatomic, copy) NSString *sdkVersion;

@property (nonatomic, copy) NSString *endpointBaseUrl;

@property (nonatomic, copy) NSString *cacheDirectoryPath;

@property (nonatomic, assign) NSTimeInterval defaultHttpConnectionTimeout;

/*! @abstract
 Time in miliseconds beatween retry requests */
@property (nonatomic, assign) NSTimeInterval httpRequestRetryTimeSpan;

@end

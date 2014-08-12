//
//  VDFBaseConfiguration.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Base configuration class
 */
@interface VDFBaseConfiguration : NSObject

/**
 *  Id of the application registered as Vodafone 3rd party app.
 */
@property (nonatomic, copy) NSString *applicationId;

/**
 *  Current version of SDK.
 */
@property (nonatomic, copy) NSString *sdkVersion;

/**
 *  Http BE host.
 */
@property (nonatomic, copy) NSString *backEndBaseUrl;

/**
 *  Http APIX host.
 */
@property (nonatomic, copy) NSString *apixBaseUrl;

/**
 *  Http connection time out.
 */
@property (nonatomic, assign) NSTimeInterval defaultHttpConnectionTimeout;

/**
 *  Time in miliseconds beatween retry requests.
 */
@property (nonatomic, assign) NSTimeInterval httpRequestRetryTimeSpan;

/**
 *  Number of maximum requests retries.
 */
@property (nonatomic, assign) NSInteger maxHttpRequestRetriesCount;

@end

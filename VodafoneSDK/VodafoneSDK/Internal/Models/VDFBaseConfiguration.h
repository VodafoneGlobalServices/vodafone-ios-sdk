//
//  VDFBaseConfiguration.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDFOAuthTokenRequestOptions;

/**
 *  Base configuration class
 */
@interface VDFBaseConfiguration : NSObject <NSCoding>

/**
 *  Key of the application registered as Vodafone 3rd party app.
 */
@property (nonatomic, copy) NSString *clientAppKey;

/**
 *  Secret of the application registered as Vodafone 3rd party app.
 */
@property (nonatomic, copy) NSString *clientAppSecret;

/**
 *  Key of the backend application registered as Vodafone 3rd party app.
 */
@property (nonatomic, copy) NSString *backendAppKey;

/**
 *  Current version of SDK.
 */
@property (nonatomic, copy) NSString *sdkVersion;

/**
 *  Http BE host.
 */
@property (nonatomic, copy) NSString *hapBaseUrl;

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

/**
 *  Number of maximum requests which can be performed in specified time period.
 */
@property (nonatomic, assign) NSInteger requestsThrottlingLimit;

/**
 *  Time period of throttling limit time period in seconds.
 */
@property (nonatomic, assign) NSTimeInterval requestsThrottlingPeriod;

/**
 *  Client id for oAuthToken retrieval.
 */
@property (nonatomic, strong) NSString *oAuthTokenClientId;

/**
 *  Client secret for oAuthToken retrieval.
 */
@property (nonatomic, strong) NSString *oAuthTokenClientSecret;

/**
 *  Scope for oAuthToken retrieval.
 */
@property (nonatomic, strong) NSString *oAuthTokenScope;

/**
 *  Dictionary of avaialable markets. (e.g. "DE": 49, "PT": 353, ...)
 */
@property (nonatomic, strong) NSDictionary *availableMarkets;

@end

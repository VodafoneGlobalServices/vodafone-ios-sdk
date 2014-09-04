//
//  VDFConsts.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#ifndef VodafoneSDK_VDFConsts_h
#define VodafoneSDK_VDFConsts_h

#pragma mark - Configuration consts:
static NSString * const CONFIGURATION_DEFAULT_OAUTH_CLIENT_ID = @"I1OpZaPfBcI378Bt7PBhQySW5Setb8eb";
static NSString * const CONFIGURATION_DEFAULT_OAUTH_CLIENT_SECRET = @"k4l1RXZGqMnw2cD8";
static NSString * const CONFIGURATION_DEFAULT_OAUTH_TOKEN_SCOPE = @"SSO_OAUTH2_INPUT";

static NSString * const CONFIGURATION_DEFAULT_HAP_BASE_URL = @"http://SeamId-4090514559.eu-de1.plex.vodafone.com";
//static NSString * const g_hapBaseURL = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
//static NSString * const g_apixBaseUrl = @"https://apisit.developer.vodafone.com";
static NSString * const CONFIGURATION_DEFAULT_APIX_BASE_URL = @"http://SeamId-4090514559.eu-de1.plex.vodafone.com";
//static NSString * const g_apixBaseUrl = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";

static NSInteger const CONFIGURATION_DEFAULT_UPDATE_CHECK_TIME_SPAN = 43200; // in secodns, 12 hours
static NSInteger const CONFIGURATION_DEFAULT_HTTP_CONNECTION_TIMEOUT = 60.0; // default 60 seconds timeout
static NSInteger const CONFIGURATION_DEFAULT_HTTP_REQUEST_RETRY_TIME_SPAN = 1000; // default time span for retry request is 1 second
static NSInteger const CONFIGURATION_DEFAULT_MAX_HTTP_REQUEST_RETRIES_COUNT = 100;

static NSString * const CONFIGURATION_CACHE_FILE_NAME = @"baseConfig.dat";



#endif

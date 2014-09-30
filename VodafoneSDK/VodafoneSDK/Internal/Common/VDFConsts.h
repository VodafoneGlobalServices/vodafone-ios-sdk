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
static NSString * const CONFIGURATION_DEFAULT_OAUTH_TOKEN_SCOPE = @"SEAMLESS_ID_RESOLVE";

static NSString * const CONFIGURATION_DEFAULT_HAP_BASE_URL = @"http://SeamId-4090514559.eu-de1.plex.vodafone.com";
//static NSString * const g_hapBaseURL = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";
//static NSString * const g_apixBaseUrl = @"https://apisit.developer.vodafone.com";
static NSString * const CONFIGURATION_DEFAULT_APIX_BASE_URL = @"https://mr-4549932930.eu-de1.plex.vodafone.com";
//static NSString * const CONFIGURATION_DEFAULT_APIX_BASE_URL = @"http://SeamId-4090514559.eu-de1.plex.vodafone.com";
//static NSString * const g_apixBaseUrl = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com";

static NSTimeInterval const CONFIGURATION_DEFAULT_UPDATE_CHECK_TIME_SPAN = 43200; // in secodns, 12 hours
static NSTimeInterval const CONFIGURATION_DEFAULT_HTTP_CONNECTION_TIMEOUT = 60.0; // default 60 seconds timeout
static NSTimeInterval const CONFIGURATION_DEFAULT_HTTP_REQUEST_RETRY_TIME_SPAN = 5000; // default time span for retry request is 5 second
static NSInteger const CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_LIMIT = 100;
static NSTimeInterval const CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_PERIOD = 60.0; // 60 seconds

static NSString * const CONFIGURATION_CACHE_FILE_NAME = @"baseConfig.dat";



// http headers consts:
static NSString * const HTTP_HEADER_ACCEPT = @"Accept";
static NSString * const HTTP_HEADER_AUTHORIZATION = @"Authorization";
static NSString * const HTTP_HEADER_USER_AGENT = @"User-Agent";
static NSString * const HTTP_HEADER_IF_NONE_MATCH = @"If-None-Match";
static NSString * const HTTP_HEADER_IF_MODIFIED_SINCE = @"If-Modified-Since";
static NSString * const HTTP_HEADER_LAST_MODIFIED = @"Last-Modified";
static NSString * const HTTP_HEADER_LOCATION = @"Location";
static NSString * const HTTP_HEADER_RETRY_AFTER = @"Retry-After";
static NSString * const HTTP_HEADER_ETAG = @"Etag";

static NSString * const HTTP_HEADER_CONTENT_TYPE = @"Content-Type";
static NSString * const HTTP_VALUE_CONTENT_TYPE_JSON = @"application/json";
static NSString * const HTTP_VALUE_CONTENT_TYPE_WWW_FORM = @"application/x-www-form-urlencoded";



// Service urls
static NSString * const SERVICE_URL_SCHEME_OAUTH_ACCESS_TOKEN = @"/2/oauth/access-token";

static NSString * const SERVICE_URL_SCHEME_RESOLVE = @"/seamless-id/users/tokens?backendId=%@";
static NSString * const SERVICE_URL_SCHEME_CHECK_RESOLVE_STATUS = @"/seamless-id/users/tokens/%@?backendId=%@";
static NSString * const SERVICE_URL_SCHEME_SEND_PIN = @"/seamless-id/users/tokens/%@/pins?backendId=%@";
static NSString * const SERVICE_URL_SCHEME_VALIDATE_PIN = @"/seamless-id/users/tokens/%@/pins?backendId=%@";

static NSString * const SERVICE_URL_SCHEME_CONFIGURATION_UPDATE = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com/v%i/sdk-config-ios/config.json";

static NSString * const ServerUrlSchema = @"";

// user resolve consts
static NSString * const CHECK_STATUS_ETAG_INITIAL_VALUE = @"etagInitialValue";


#endif

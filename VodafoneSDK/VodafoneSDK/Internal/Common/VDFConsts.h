//
//  VDFConsts.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#ifndef VodafoneSDK_VDFConsts_h
#define VodafoneSDK_VDFConsts_h

// current version of SDK
#define VDF_IOS_SDK_VERSION_STRING @"1.0.3"

// is Production Build
// #define VDF_PRODUCTION 1

#pragma mark - Configuration consts:

static NSString * const CONFIGURATION_DEFAULT_OAUTH_TOKEN_GRANT_TYPE = @"client_credentials";
static NSString * const CONFIGURATION_DEFAULT_OAUTH_TOKEN_SCOPE = @"seamless_id_resolve";

#ifdef VDF_PRODUCTION
static NSString * const CONFIGURATION_DEFAULT_HAP_HOST = @"http://ihap.sp.vodafone.com";
static NSString * const CONFIGURATION_DEFAULT_APIX_HOST = @"https://api.developer.vodafone.com";
#else
static NSString * const CONFIGURATION_DEFAULT_HAP_HOST = @"http://ihap-pre.sp.vodafone.com";
static NSString * const CONFIGURATION_DEFAULT_APIX_HOST = @"https://apisit.developer.vodafone.com";
#endif

static NSTimeInterval const CONFIGURATION_DEFAULT_UPDATE_CHECK_TIME_SPAN = 43200; // in seconds, 12 hours
static NSTimeInterval const CONFIGURATION_DEFAULT_HTTP_CONNECTION_TIMEOUT = 60.0; // default 60 seconds timeout
static NSInteger const CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_LIMIT = 10;
static NSTimeInterval const CONFIGURATION_DEFAULT_REQUESTS_THROTTLING_PERIOD = 60.0; // 60 seconds
static NSString * const CONFIGURATION_DEFAULT_PHONE_NUMBER_REGEX = @"^[0-9]{7,12}$"; // default phone number validation regex
static NSString * const CONFIGURATION_DEFAULT_SMS_CODE_REGEX = @"^[0-9]{4}$"; // default sms code validation regex

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
static NSString * const HTTP_HEADER_CACHE_CONTROL = @"Cache-Control";

static NSString * const HTTP_HEADER_CONTENT_TYPE = @"Content-Type";
static NSString * const HTTP_VALUE_CONTENT_TYPE_JSON = @"application/json";
static NSString * const HTTP_VALUE_CONTENT_TYPE_WWW_FORM = @"application/x-www-form-urlencoded";



// Service urls
static NSString * const SERVICE_URL_DEFAULT_OAUTH_TOKEN_PATH = @"/2/oauth/access-token";
static NSString * const SERVICE_URL_DEFAULT_BASE_PATH = @"/seamless-id/users/tokens";

static NSString * const SERVICE_URL_PATH_SCHEME_RESOLVE = @"?backendId=%@";
static NSString * const SERVICE_URL_PATH_SCHEME_CHECK_RESOLVE_STATUS = @"/%@?backendId=%@";
static NSString * const SERVICE_URL_PATH_SCHEME_SEND_PIN = @"/%@/pins?backendId=%@";
static NSString * const SERVICE_URL_PATH_SCHEME_VALIDATE_PIN = @"/%@/pins?backendId=%@";

static NSString * const SERVICE_URL_SCHEME_CONFIGURATION_UPDATE = @"https://appconfig.shared.sp.vodafone.com/seamless-id/v%i/sdk-config-ios/config.json";



// user resolve consts
static NSString * const CHECK_STATUS_ETAG_INITIAL_VALUE = @"etagInitialValue";

#endif

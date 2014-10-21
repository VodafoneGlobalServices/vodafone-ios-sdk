//
//  VDFBaseConfiguration.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseConfiguration.h"
#import "VDFBaseConfiguration+Manager.h"

static NSString * const HapHostKey = @"hapHost";
static NSString * const ApixHostKey = @"apixHost";
static NSString * const OAuthTokenUrlPathKey = @"oAuthTokenUrlPath";
static NSString * const OAuthTokenScopeKey = @"oAuthTokenScope";
static NSString * const OAuthTokenGrantTypeKey = @"oAuthTokenGrantType";
static NSString * const ServiceBasePathKey = @"serviceBasePath";
static NSString * const DefaultHttpConnectionTimeoutKey = @"defaultHttpConnectionTimeout";
static NSString * const RequestsThrottlingLimitKey = @"requestsThrottlingLimit";
static NSString * const RequestsThrottlingPeriodKey = @"requestsThrottlingPeriod";
static NSString * const AvailableMarketsKey = @"availableMarkets";
static NSString * const PhoneNumberRegexKey = @"phoneNumberRegex";
static NSString * const AvailableMccMncKey = @"availableMccMnc";
static NSString * const ConfigurationUpdateLastModifiedKey = @"configurationUpdateLastModified";
static NSString * const ConfigurationUpdateEtagKey = @"configurationUpdateEtag";

@implementation VDFBaseConfiguration

#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        self.hapHost = [decoder decodeObjectForKey:HapHostKey];
        self.apixHost = [decoder decodeObjectForKey:ApixHostKey];
        self.oAuthTokenUrlPath = [decoder decodeObjectForKey:OAuthTokenUrlPathKey];
        self.oAuthTokenScope = [decoder decodeObjectForKey:OAuthTokenScopeKey];
        self.oAuthTokenGrantType = [decoder decodeObjectForKey:OAuthTokenGrantTypeKey];
        self.serviceBasePath = [decoder decodeObjectForKey:ServiceBasePathKey];
        self.defaultHttpConnectionTimeout = [decoder decodeDoubleForKey:DefaultHttpConnectionTimeoutKey];
        self.requestsThrottlingLimit = [decoder decodeIntegerForKey:RequestsThrottlingLimitKey];
        self.requestsThrottlingPeriod = [decoder decodeDoubleForKey:RequestsThrottlingPeriodKey];
        self.availableMarkets = [decoder decodeObjectForKey:AvailableMarketsKey];
        self.phoneNumberRegex = [decoder decodeObjectForKey:PhoneNumberRegexKey];
        self.availableMccMnc = [decoder decodeObjectForKey:AvailableMccMncKey];
        self.configurationUpdateLastModified = [decoder decodeObjectForKey:ConfigurationUpdateLastModifiedKey];
        self.configurationUpdateEtag = [decoder decodeObjectForKey:ConfigurationUpdateEtagKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.hapHost forKey:HapHostKey];
    [encoder encodeObject:self.apixHost forKey:ApixHostKey];
    [encoder encodeObject:self.oAuthTokenUrlPath forKey:OAuthTokenUrlPathKey];
    [encoder encodeObject:self.oAuthTokenScope forKey:OAuthTokenScopeKey];
    [encoder encodeObject:self.oAuthTokenGrantType forKey:OAuthTokenGrantTypeKey];
    [encoder encodeObject:self.serviceBasePath forKey:ServiceBasePathKey];
    [encoder encodeDouble:self.defaultHttpConnectionTimeout forKey:DefaultHttpConnectionTimeoutKey];
    [encoder encodeInteger:self.requestsThrottlingLimit forKey:RequestsThrottlingLimitKey];
    [encoder encodeDouble:self.requestsThrottlingPeriod forKey:RequestsThrottlingPeriodKey];
    [encoder encodeObject:self.availableMarkets forKey:AvailableMarketsKey];
    [encoder encodeObject:self.phoneNumberRegex forKey:PhoneNumberRegexKey];
    [encoder encodeObject:self.availableMccMnc forKey:AvailableMccMncKey];
    [encoder encodeObject:self.configurationUpdateLastModified forKey:ConfigurationUpdateLastModifiedKey];
    [encoder encodeObject:self.configurationUpdateEtag forKey:ConfigurationUpdateEtagKey];
}



- (BOOL)updateWithJson:(NSDictionary*)jsonObjectDictionary {
    /*
    {
        "hap": {
            "protocol": "http",
            "host": "ihap-pre.sp.vodafone.com"
        },
        "apix": {
            "protocol": "https",
            "host": "apisit.developer.vodafone.com",
            "oAuthTokenPath": "/2/oauth/access-token",
            "oAuthTokenScope": "seamless_id_resolve",
            "oAuthTokenGrantType": "client_credentials"
        },
        "basePath": "/seamless-id/users/tokens",
        "defaultHttpConnectionTimeout": 60,
        "requestsThrottlingLimit": 10,
        "requestsThrottlingPeriod": 60,
        "availableMarkets" : {"PT": 351,"IT": 39,"DE": 49,"ES": 34,"IE": 353,"NL": 31,"GB": 44,"RO": 40,"HU": 36,"GR": 30,"MT": 356,"AL": 355,"CZ": 420,"ZA": 27},
        "phoneNumberRegex": "^[0-9]{7,12}$",
        "availableMccMnc": ["26801","22210","26202","21401","27201","20404","23415","22601","21670","20205","27801","27602","23003","65501"]
    }
     */
    // each timeout property is in seconds
    
    BOOL isValid = YES;
    
    NSString *json_hapProtocol = nil;
    NSString *json_hapHost = nil;
    NSString *json_apixProtocol = nil;
    NSString *json_apixHost = nil;
    NSString *json_oAuthTokenUrlPath = nil;
    NSString *json_oAuthTokenScope = nil;
    NSString *json_oAuthTokenGrantType = nil;
    NSString *json_serviceBasePath = nil;
    id json_defaultHttpConnectionTimeout = nil;
    id json_requestsThrottlingLimit = nil;
    id json_requestsThrottlingPeriod = nil;
    NSString *json_phoneNumberRegex = nil;
    NSDictionary *json_availableMarkets = nil;
    NSArray *json_availableMccMnc = nil;
    
    
    NSDictionary *hapDictionary = [jsonObjectDictionary valueForKey:@"hap"];
    if(hapDictionary != nil && [hapDictionary isKindOfClass:[NSDictionary class]]) {
        // setting hap host:
        json_hapProtocol = [hapDictionary valueForKey:@"protocol"];
        json_hapHost = [hapDictionary valueForKey:@"host"];
        isValid = isValid && json_hapProtocol != nil && ![json_hapProtocol isEqualToString:[NSString string]];
        isValid = isValid && json_hapHost != nil && ![json_hapHost isEqualToString:[NSString string]];
    }
    else {
        isValid = NO;
    }
    
    NSDictionary *apixDictionary = [jsonObjectDictionary valueForKey:@"apix"];
    if(apixDictionary != nil && [apixDictionary isKindOfClass:[NSDictionary class]]) {
        // setting apix host
        json_apixProtocol = [apixDictionary valueForKey:@"protocol"];
        json_apixHost = [apixDictionary valueForKey:@"host"];
        isValid = isValid && json_apixProtocol != nil && ![json_apixProtocol isEqualToString:[NSString string]];
        isValid = isValid && json_apixHost != nil && ![json_apixHost isEqualToString:[NSString string]];
        
        json_oAuthTokenUrlPath = [apixDictionary valueForKey:@"oAuthTokenPath"];
        json_oAuthTokenScope = [apixDictionary valueForKey:@"oAuthTokenScope"];
        json_oAuthTokenGrantType = [apixDictionary valueForKey:@"oAuthTokenGrantType"];
        
        isValid = isValid && json_oAuthTokenUrlPath != nil && ![json_oAuthTokenUrlPath isEqualToString:[NSString string]];
        isValid = isValid && json_oAuthTokenScope != nil && ![json_oAuthTokenScope isEqualToString:[NSString string]];
        isValid = isValid && json_oAuthTokenGrantType != nil && ![json_oAuthTokenGrantType isEqualToString:[NSString string]];
    }
    else {
        isValid = NO;
    }
    
    
    json_serviceBasePath = [jsonObjectDictionary valueForKey:@"basePath"];
    json_defaultHttpConnectionTimeout = [jsonObjectDictionary valueForKey:@"defaultHttpConnectionTimeout"];
    json_requestsThrottlingLimit = [jsonObjectDictionary valueForKey:@"requestsThrottlingLimit"];
    json_requestsThrottlingPeriod = [jsonObjectDictionary valueForKey:@"requestsThrottlingPeriod"];
    json_phoneNumberRegex = [jsonObjectDictionary valueForKey:@"phoneNumberRegex"];
    
    isValid = isValid && json_serviceBasePath != nil && ![json_serviceBasePath isEqualToString:[NSString string]];
    isValid = isValid && json_defaultHttpConnectionTimeout != nil;
    isValid = isValid && json_requestsThrottlingLimit != nil;
    isValid = isValid && json_requestsThrottlingPeriod != nil;
    isValid = isValid && json_phoneNumberRegex != nil && ![json_phoneNumberRegex isEqualToString:[NSString string]];
    
    json_availableMarkets = [jsonObjectDictionary valueForKey:@"availableMarkets"];
    isValid = isValid && json_availableMarkets != nil && [json_availableMarkets isKindOfClass:[NSDictionary class]];
    
    json_availableMccMnc = [jsonObjectDictionary valueForKey:@"availableMccMnc"];
    isValid = isValid && json_availableMccMnc != nil && [json_availableMccMnc isKindOfClass:[NSArray class]];
    
    if(isValid) {
        self.hapHost = [NSString stringWithFormat:@"%@://%@", json_hapProtocol, json_hapHost];
        self.apixHost = [NSString stringWithFormat:@"%@://%@", json_apixProtocol, json_apixHost];
        
        self.oAuthTokenUrlPath = [apixDictionary valueForKey:@"oAuthTokenPath"];
        self.oAuthTokenScope = [apixDictionary valueForKey:@"oAuthTokenScope"];
        self.oAuthTokenGrantType = [apixDictionary valueForKey:@"oAuthTokenGrantType"];
        
        self.serviceBasePath = json_serviceBasePath;
        self.defaultHttpConnectionTimeout = [json_defaultHttpConnectionTimeout intValue];
        self.requestsThrottlingLimit = [json_requestsThrottlingLimit intValue];
        self.requestsThrottlingPeriod = [json_requestsThrottlingPeriod intValue];
        self.phoneNumberRegex = json_phoneNumberRegex;
        
        self.availableMarkets = json_availableMarkets;
        self.availableMccMnc = json_availableMccMnc;
    }
    return isValid;
}

@end

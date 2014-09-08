//
//  VDFBaseConfiguration.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseConfiguration.h"
#import "VDFBaseConfiguration+Manager.h"

static NSString * const DefaultHttpConnectionTimeoutKey = @"defaultHttpConnectionTimeout";
static NSString * const HttpRequestRetryTimeSpanKey = @"httpRequestRetryTimeSpan";
static NSString * const MaxHttpRequestRetriesCountKey = @"maxHttpRequestRetriesCount";
static NSString * const RequestsThrottlingLimitKey = @"requestsThrottlingLimit";
static NSString * const RequestsThrottlingPeriodKey = @"requestsThrottlingPeriod";
static NSString * const ConfigurationLastModifiedDateKey = @"configurationLastModifiedDate";
static NSString * const ConfigurationUpdateCheckTimeSpanKey = @"configurationUpdateCheckTimeSpan";


@implementation VDFBaseConfiguration

#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        self.defaultHttpConnectionTimeout = [decoder decodeDoubleForKey:DefaultHttpConnectionTimeoutKey];
        self.httpRequestRetryTimeSpan = [decoder decodeDoubleForKey:HttpRequestRetryTimeSpanKey];
        self.maxHttpRequestRetriesCount = [decoder decodeIntegerForKey:MaxHttpRequestRetriesCountKey];
        self.requestsThrottlingLimit = [decoder decodeIntegerForKey:RequestsThrottlingLimitKey];
        self.requestsThrottlingPeriod = [decoder decodeDoubleForKey:RequestsThrottlingPeriodKey];
        self.configurationLastModifiedDate = [decoder decodeObjectForKey:ConfigurationLastModifiedDateKey];
        self.configurationUpdateCheckTimeSpan = [decoder decodeDoubleForKey:ConfigurationUpdateCheckTimeSpanKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeDouble:self.defaultHttpConnectionTimeout forKey:DefaultHttpConnectionTimeoutKey];
    [encoder encodeDouble:self.httpRequestRetryTimeSpan forKey:HttpRequestRetryTimeSpanKey];
    [encoder encodeInteger:self.maxHttpRequestRetriesCount forKey:MaxHttpRequestRetriesCountKey];
    [encoder encodeInteger:self.requestsThrottlingLimit forKey:RequestsThrottlingLimitKey];
    [encoder encodeDouble:self.requestsThrottlingPeriod forKey:RequestsThrottlingPeriodKey];
    [encoder encodeObject:self.configurationLastModifiedDate forKey:ConfigurationLastModifiedDateKey];
    [encoder encodeDouble:self.configurationUpdateCheckTimeSpan forKey:ConfigurationUpdateCheckTimeSpanKey];
}



- (void)updateWithJson:(NSDictionary*)jsonObjectDictionary {
    self.configurationLastModifiedDate = [NSDate date];
    // TODO when we will know how this json file will looks like
}

@end

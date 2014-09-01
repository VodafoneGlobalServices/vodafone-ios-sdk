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
static NSString * const ConfigurationLastUpdateDateKey = @"configurationLastUpdateDate";
static NSString * const ConfigurationValidityTimeSpanKey = @"configurationValidityTimeSpan";


@implementation VDFBaseConfiguration

#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        self.defaultHttpConnectionTimeout = [decoder decodeDoubleForKey:DefaultHttpConnectionTimeoutKey];
        self.httpRequestRetryTimeSpan = [decoder decodeDoubleForKey:HttpRequestRetryTimeSpanKey];
        self.maxHttpRequestRetriesCount = [decoder decodeIntegerForKey:MaxHttpRequestRetriesCountKey];
        self.configurationLastUpdateDate = [decoder decodeObjectForKey:ConfigurationLastUpdateDateKey];
        self.configurationValidityTimeSpan = [decoder decodeDoubleForKey:ConfigurationValidityTimeSpanKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeDouble:self.defaultHttpConnectionTimeout forKey:DefaultHttpConnectionTimeoutKey];
    [encoder encodeDouble:self.httpRequestRetryTimeSpan forKey:HttpRequestRetryTimeSpanKey];
    [encoder encodeInteger:self.maxHttpRequestRetriesCount forKey:MaxHttpRequestRetriesCountKey];
    [encoder encodeObject:self.configurationLastUpdateDate forKey:ConfigurationLastUpdateDateKey];
    [encoder encodeDouble:self.configurationValidityTimeSpan forKey:ConfigurationValidityTimeSpanKey];
}

@end

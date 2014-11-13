//
//  VDFConfigurationDownloader.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 02/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFConfigurationUpdater.h"
#import "VDFHttpConnector.h"
#import "VDFLogUtility.h"
#import "VDFErrorUtility.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFBaseConfiguration+Manager.h"
#import "VDFConsts.h"

//static NSInteger const NotModifiedHttpCode = 304;
static NSInteger const SuccessHttpCode = 200;
static NSInteger const VersionNumber = 1;

@interface VDFConfigurationUpdater ()
@property (nonatomic, strong) UpdateCompletionHandler completionHandler;
@property (nonatomic, strong) VDFHttpConnector *httpConnector;
@end

@implementation VDFConfigurationUpdater

- (instancetype)initWithConfiguration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        self.configurationToUpdate = configuration;
    }
    return self;
}

- (void)dealloc {
    if(self.httpConnector != nil) {
        [self.httpConnector cancelCommunication];
    }
}

- (void)startUpdateWithCompletionHandler:(UpdateCompletionHandler)completionHandler {
    self.completionHandler = completionHandler;
    
    self.httpConnector = [[VDFHttpConnector alloc] initWithDelegate:self];
    self.httpConnector.connectionTimeout = 60;
    self.httpConnector.methodType = HTTPMethodGET;
    self.httpConnector.url = [NSString stringWithFormat:SERVICE_URL_SCHEME_CONFIGURATION_UPDATE, VersionNumber];
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setObject:HTTP_VALUE_CONTENT_TYPE_JSON forKey:HTTP_HEADER_ACCEPT];
    if(self.configurationToUpdate.configurationUpdateEtag != nil) {
        [headers setObject:self.configurationToUpdate.configurationUpdateEtag forKey:HTTP_HEADER_IF_NONE_MATCH];
    }
    if(self.configurationToUpdate.configurationUpdateLastModified != nil) {
        [headers setObject:self.configurationToUpdate.configurationUpdateLastModified forKey:HTTP_HEADER_IF_MODIFIED_SINCE];
    }
    
    self.httpConnector.requestHeaders = headers;
    if(![self.httpConnector startCommunication]) {
        self.completionHandler(self, NO);
    }
}

#pragma mark -
#pragma mark - VDFHttpConnectorDelegate implementation

- (void)httpRequest:(VDFHttpConnector*)request onResponse:(VDFHttpConnectorResponse*)response {
    
    VDFLogI(@"On configuration update http response\nHttp response code: %i\nHttp response headers: \n%@\nHttp response data string: \n--->%@<---",
            request.lastResponseCode, response.responseHeaders, [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding]);
    
    if(response.httpResponseCode == SuccessHttpCode) {
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:&error];
        BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
        
        if(![VDFErrorUtility handleInternalError:error] && isResponseValid) {
            
            // parse max-age from cache control:
            NSString *cacheControl = [response.responseHeaders objectForKey:HTTP_HEADER_CACHE_CONTROL];
            if(cacheControl) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(max-age|s-maxage)=\\s*([0-9]+)[\\s,]*" options:NSRegularExpressionCaseInsensitive error:nil];
                NSTextCheckingResult *match = [regex firstMatchInString:cacheControl options:0 range:NSMakeRange(0, [cacheControl length])];
                NSRange maxAgeRange = [match rangeAtIndex:2];
                if(maxAgeRange.location != NSNotFound) {
                    NSInteger maxAgeSeconds = [[cacheControl substringWithRange:maxAgeRange] intValue];
                    self.configurationToUpdate.nextUpdateTime = [NSDate dateWithTimeIntervalSinceNow:maxAgeSeconds];
                }
            }
            
            // check is something changed (if etag has changed - if still the same then this is readed from http cache)
            NSString *etag = [response.responseHeaders objectForKey:HTTP_HEADER_ETAG];
            if(etag && (self.configurationToUpdate.configurationUpdateEtag == nil
                        || ![self.configurationToUpdate.configurationUpdateEtag isEqualToString:etag])) {

                self.configurationToUpdate.configurationUpdateEtag = etag;
                
                NSString *lastModifiedString = [response.responseHeaders objectForKey:HTTP_HEADER_LAST_MODIFIED];
                if(lastModifiedString) {
                    self.configurationToUpdate.configurationUpdateLastModified = lastModifiedString;
                }
                
                // object parsed correctly
                // and update it:
                if([self.configurationToUpdate updateWithJson:jsonObject]) {
                    VDFLogI(@"SDK Configuration was updated.");
                    self.completionHandler(self, YES);
                    return;
                }
            }
        }
    }
    VDFLogI(@"SDK Configuration was not updated, beacause new configuration was invaild or readed from http cache.");
    self.completionHandler(self, NO);
}

@end

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
    self.httpConnector.useCachePolicy = YES;
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
    if([self.httpConnector startCommunication] != 0) {
        self.completionHandler(self, NO);
    }
}

#pragma mark -
#pragma mark - VDFHttpConnectorDelegate implementation

- (void)httpRequest:(VDFHttpConnector*)request onResponse:(VDFHttpConnectorResponse*)response {
    
    VDFLogI(@"On configuration update http response");
    VDFLogI(@"Http response code: \n%i", request.lastResponseCode);
    VDFLogI(@"Http response headers: \n%@", response.responseHeaders);
    VDFLogI(@"Http response data string: \n--->%@<---", [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding]);
    
    if(response.httpResponseCode == SuccessHttpCode) {
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:&error];
        BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
        
        if(![VDFErrorUtility handleInternalError:error] && isResponseValid) {
            
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
                [self.configurationToUpdate updateWithJson:jsonObject];
                self.completionHandler(self, YES);
                return;

            }
        }
    }
    self.completionHandler(self, NO);
}

@end

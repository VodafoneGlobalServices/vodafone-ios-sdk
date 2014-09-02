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

static NSInteger const NotModifiedHttpCode = 304;
static NSInteger const SuccessHttpCode = 200;
static NSInteger const VersionNumber = 1;
static NSString * const ServerUrlSchema = @"http://hebemock-4953648878.eu-de1.plex.vodafone.com/v%i/sdk-config-ios/config.json";

@interface VDFConfigurationUpdater ()
@property (nonatomic, assign) UpdateCompletionHandler completionHandler;
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
    self.httpConnector.url = [NSString stringWithFormat:ServerUrlSchema, VersionNumber];
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    [headers setObject:@"application/json" forKey:@"Accept"];
    if(self.configurationToUpdate.configurationUpdateEtag != nil) {
        [headers setObject:self.configurationToUpdate.configurationUpdateEtag forKey:@"If-None-Match"];
    }
    if(self.configurationToUpdate.configurationLastModifiedDate != nil) {
        [headers setObject:[NSString stringWithFormat:@"%@", self.configurationToUpdate.configurationLastModifiedDate] forKey:@"If-Modified-Since"]; // TODO move this hardcoded strings to another file
    }
    
//    httpRequest.requestHeaders = @{: , /*@"User-Agent": [VDFSettings sdkVersion], @"Application-ID": self.builder.applicationId*/};
    self.httpConnector.requestHeaders = headers;
    [self.httpConnector startCommunication];
}

#pragma mark -
#pragma mark - VDFHttpConnectorDelegate implementation

- (void)httpRequest:(VDFHttpConnector*)request onResponse:(VDFHttpConnectorResponse*)response {
    
    if(response.httpResponseCode == SuccessHttpCode) {
        VDFLogD(@"Parsing response of configuration update: %@", response.data);
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:&error];
        BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
        
        if(![VDFErrorUtility handleInternalError:error] || !isResponseValid) {
            // object parsed correctly
            // and update it:
            [self.configurationToUpdate updateWithJson:jsonObject];
            self.completionHandler(self, YES);
            return;
        }
    }
    self.completionHandler(self, NO);
}

@end

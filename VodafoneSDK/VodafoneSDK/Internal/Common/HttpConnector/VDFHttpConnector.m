//
//  HttpRequest.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFHttpConnector.h"
#import "VDFError.h"
#import "VDFLogUtility.h"
#import "VDFStringHelper.h"
#import "VDFDeviceUtility.h"
#import "VDFSettings.h"
#import "VDFSettings+Internal.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFDIContainer.h"
#import "VDFConsts.h"
#import "VDFSettings.h"
#import "VDFSettings+Internal.h"
#import "VDFDeviceUtility.h"

static NSString * const XVF_SUBJECT_ID_HEADER = @"x-vf-trace-subject-id";
static NSString * const XVF_SUBJECT_REGION_HEADER = @"x-vf-trace-subject-region";
static NSString * const XVF_SOURCE_HEADER = @"x-vf-trace-source";
static NSString * const XVF_TRANSACTION_ID_HEADER = @"x-vf-trace-transaction-id";


@interface VDFHttpConnector ()
@property (nonatomic, assign) id<VDFHttpConnectorDelegate> delegate;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) VDFDeviceUtility *deviceUtility;

- (void)addHeadersToRequest:(NSMutableURLRequest*)request;
- (void)get:(NSString*)url;
- (void)post:(NSString*)url withBody:(NSData*)body;
@end

@implementation VDFHttpConnector

@synthesize lastResponseCode = _lastResponseCode;

- (instancetype)initWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        self.connectionTimeout = 60.0; // default if is not set from outside
        _lastResponseCode = 0;
        self.currentConnection = nil;
        self.allowRedirects = YES;
        self.useCachePolicy = NO;
        self.deviceUtility = [[VDFSettings globalDIContainer] resolveForClass:[VDFDeviceUtility class]];
    }
    return self;
}

- (NSInteger)startCommunication {
    
    VDFNetworkAvailability networkAvailability = [self.deviceUtility checkNetworkTypeAvailability];
    
    if(networkAvailability == VDFNetworkNotAvailable) {
        VDFLogI(@"Internet is not available.");
        return 1;
    }
    else if (networkAvailability != VDFNetworkAvailableViaGSM && self.isGSMConnectionRequired) {
        VDFLogI(@"Request need 3G connection - there is not available any.");
        // not connected over 3G and request require 3G:
        return 2; // TODO need to make some error codes for this
    }
    else {
        VDFLogI(@"Performing HTTP request");
        
        // starting the request
        if([NSThread isMainThread]) {
            if(self.methodType == HTTPMethodPOST) {
                [self post:self.url withBody:self.postBody];
            }
            else {
                [self get:self.url];
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.methodType == HTTPMethodPOST) {
                    [self post:self.url withBody:self.postBody];
                }
                else {
                    [self get:self.url];
                }
            });
        }
    }

    return 0;
}

- (void)cancelCommunication {
    self.delegate = nil;
    if([self isRunning]) {
        [self.currentConnection cancel];
    }
}

- (BOOL)isRunning {
    return self.currentConnection != nil;
}

#pragma mark -
#pragma mark Private implementation

- (void)addHeadersToRequest:(NSMutableURLRequest*)request {
    
    if(self.requestHeaders != nil) {
        for (NSString *headerKey in [self.requestHeaders allKeys]) {
            [request setValue:[self.requestHeaders valueForKey:headerKey] forHTTPHeaderField:headerKey];
        }
    }
    
    VDFDeviceUtility *deviceUtility = [[VDFSettings globalDIContainer] resolveForClass:[VDFDeviceUtility class]];
    
    // always we adding this standard headers
    [request setValue:[NSString stringWithFormat:@"%@\%@\%@", [deviceUtility deviceHardwareName], [deviceUtility osName], [deviceUtility deviceUniqueIdentifier]] forHTTPHeaderField:XVF_SUBJECT_ID_HEADER];
    NSString *mcc = [VDFDeviceUtility simMCC];
    if(mcc != nil) {
        [request setValue:mcc forHTTPHeaderField:XVF_SUBJECT_REGION_HEADER];
    }
    VDFBaseConfiguration *configuration = [[VDFSettings globalDIContainer] resolveForClass:[VDFBaseConfiguration class]];
    [request setValue:[NSString stringWithFormat:@"VFSeamlessID SDK/iOS (v%@)-%@-%@", [VDFSettings sdkVersion], configuration.clientAppKey, configuration.backendAppKey] forHTTPHeaderField:XVF_SOURCE_HEADER];
    [request setValue:[VDFStringHelper randomString] forHTTPHeaderField:XVF_TRANSACTION_ID_HEADER];
    [request setValue:[NSString stringWithFormat:@"VFSeamlessID SDK/iOS (v%@)", [VDFSettings sdkVersion]] forHTTPHeaderField:HTTP_HEADER_USER_AGENT];
//   
//    [request setValue:@"DE" forHTTPHeaderField:@"x-int-opco"]; // TODO IMPORTANT only for testing purpose, against http://SeamId-4090514559.eu-de1.plex.vodafone.com backend
//    [request setValue:@"447880400514" forHTTPHeaderField:@"x-sdp-msisdn"]; // TODO IMPORTANT only for testing purpose, against apix test backend
//    
//    
//    
//    [request setValue:@"seamless_id_user_details_all" forHTTPHeaderField:@"scope"]; // TODO IMPORTANT only for testing purpose, against http://SeamId-4090514559.eu-de1.plex.vodafone.com backend
//    [request setValue:@"seamless_id_user_details_all" forHTTPHeaderField:@"backendScopes"]; // TODO IMPORTANT only for testing purpose, against http://SeamId-4090514559.eu-de1.plex.vodafone.com backend
//
}
 
- (void)get:(NSString*)url {
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                            cachePolicy:self.useCachePolicy ? NSURLRequestReturnCacheDataElseLoad:NSURLRequestReloadIgnoringLocalCacheData
                 timeoutInterval:self.connectionTimeout];
    
    [self addHeadersToRequest:request];
    
    VDFLogI(@"GET %@\nHeaders %@", url, [request allHTTPHeaderFields]);
    
    self.url = url;
    self.receivedData = [NSMutableData data];
    self.responseHeaders = [NSDictionary dictionary];
    
    // sending request:
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    if(self.currentConnection == nil) {
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        if(self.delegate != nil) {
            [self.delegate httpRequest:self onResponse:[[VDFHttpConnectorResponse alloc] initWithError:error]];
        }
    }
    
}

- (void)post:(NSString*)url withBody:(NSData*)body
{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString: url]
                            cachePolicy:self.useCachePolicy ? NSURLRequestReturnCacheDataElseLoad:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:self.connectionTimeout];
    
    request.HTTPMethod = @"POST";
    
    //[request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
//    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    
    [self addHeadersToRequest:request];
    
    [request setHTTPBody:body];
    
    VDFLogI(@"POST %@\nHeaders %@\n------\n%@\n------", url, [request allHTTPHeaderFields], [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    
    self.url = url;
    self.receivedData = [NSMutableData data];
    self.responseHeaders = [NSDictionary dictionary];
    
    // sending request:
    self.currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(self.currentConnection == nil) {
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        if(self.delegate != nil) {
            [self.delegate httpRequest:self onResponse:[[VDFHttpConnectorResponse alloc] initWithError:error]];
        }
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if(redirectResponse && !self.allowRedirects) {
        return nil;
    }
    else {
        return request;
    }
}

// TODO VERY IMPORTANT - in release for production we need to remove accepting of all ssl certificates !!!!!!

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // accepting all ssl certificates
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    [self.receivedData setLength:0];
    _lastResponseCode = [(NSHTTPURLResponse*)response statusCode];
    self.responseHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
//    VDFLogD(@"didReceiveResponse for url %@, with response code: %i, with headers: %@", self.url, _lastResponseCode, self.responseHeaders);
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [self.receivedData appendData:data];
//    VDFLogD(@"didReceiveData for url %@", self.url);
}


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    self.currentConnection = nil;
//    VDFLogD(@"didFailWithError for url %@", self.url);
    NSError *errorInVDFDomain = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
    if(self.delegate != nil) {
        [self.delegate httpRequest:self onResponse:[[VDFHttpConnectorResponse alloc] initWithError:errorInVDFDomain]];
    }
}



- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    self.currentConnection = nil;
//    VDFLogD(@"connectionDidFinishLoading for url %@", self.url);
    if(self.delegate != nil) {
        [self.delegate httpRequest:self onResponse:[[VDFHttpConnectorResponse alloc] initWithData:self.receivedData httpCode:self.lastResponseCode headers:self.responseHeaders]];
    }
}





@end

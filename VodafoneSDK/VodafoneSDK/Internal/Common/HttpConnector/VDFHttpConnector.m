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
#import "VDFNetworkReachability.h"
#import "VDFStringHelper.h"
#import "VDFDeviceUtility.h"
#import "VDFSettings.h"
#import "VDFSettings+Internal.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFDIContainer.h"

static NSString * const XVF_SUBJECT_ID_HEADER = @"x-vf-trace-subject-id";
static NSString * const XVF_SUBJECT_REGION_HEADER = @"x-vf-trace-subject-region";
static NSString * const XVF_SOURCE_HEADER = @"x-vf-trace-source";
static NSString * const XVF_TRANSACTION_ID_HEADER = @"x-vf-trace-transaction-id";


@interface VDFHttpConnector ()
@property (nonatomic, assign) id<VDFHttpConnectorDelegate> delegate;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, assign) BOOL isConnectionOpen;

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
        self.isConnectionOpen = NO;
    }
    return self;
}

- (NSInteger)startCommunication {
    
    VDFNetworkReachability *reachability = [VDFNetworkReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable) {
        VDFLogD(@"Internet is not avaialble.");
        return 1;
    }
    else if (status != ReachableViaWWAN && self.isGSMConnectionRequired) {
        VDFLogD(@"Request need 3G connection - there is not available any.");
        // not connected over 3G and request require 3G:
        return 2; // TODO need to make some error codes for this
    }
    else {
        
        // starting the request
        if(self.methodType == HTTPMethodPOST) {
            [self post:self.url withBody:self.postBody];
        }
        else {
            [self get:self.url];
        }
        VDFLogD(@"Request started.");
    }

    return 0;
}

- (void)cancelCommunication {
    self.delegate = nil;
    // TODO
}

- (BOOL)isRunning {
    return self.isConnectionOpen;
}

#pragma mark -
#pragma mark Private implementation

- (void)addHeadersToRequest:(NSMutableURLRequest*)request {
    
    if(self.requestHeaders != nil) {
        for (NSString *headerKey in [self.requestHeaders allKeys]) {
            [request setValue:[self.requestHeaders valueForKey:headerKey] forHTTPHeaderField:headerKey];
        }
    }
    
    // always we adding this standard headers
    [request setValue:[VDFDeviceUtility deviceUniqueIdentifier] forHTTPHeaderField:XVF_SUBJECT_ID_HEADER];
    NSString *mcc = [VDFDeviceUtility simMCC];
    if(mcc != nil) {
        [request setValue:mcc forHTTPHeaderField:XVF_SUBJECT_REGION_HEADER];
    }
    VDFBaseConfiguration *configuration = [[VDFSettings globalDIContainer] resolveForClass:[VDFBaseConfiguration class]];
    [request setValue:[NSString stringWithFormat:@"%@-%@", [VDFSettings sdkVersion], configuration.applicationId] forHTTPHeaderField:XVF_SOURCE_HEADER];
    [request setValue:[VDFStringHelper randomString] forHTTPHeaderField:XVF_TRANSACTION_ID_HEADER];
}

- (void)get:(NSString*)url {
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                 timeoutInterval:self.connectionTimeout];
    
    [self addHeadersToRequest:request];
    
    // sending request:
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    VDFLogD(@"GET %@", url);
    
    if(conn) {
        self.isConnectionOpen = YES;
        self.url = url;
        self.receivedData = [NSMutableData data];
    }
    else {
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
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:self.connectionTimeout];
    
    request.HTTPMethod = @"POST";
    
    //[request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    
    [self addHeadersToRequest:request];
    
    [request setHTTPBody:body];
    
    VDFLogD(@"POST %@\n------\n%@\n------", url, [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    
    // sending request:
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn) {
        self.isConnectionOpen = YES;
        self.url = url;
        self.receivedData = [NSMutableData data];
        self.responseHeaders = [NSArray array];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        if(self.delegate != nil) {
            [self.delegate httpRequest:self onResponse:[[VDFHttpConnectorResponse alloc] initWithError:error]];
        }
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

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
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [self.receivedData appendData:data];
}


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    self.isConnectionOpen = NO;
    NSError *errorInVDFDomain = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
    if(self.delegate != nil) {
        [self.delegate httpRequest:self onResponse:[[VDFHttpConnectorResponse alloc] initWithError:errorInVDFDomain]];
    }
}



- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    self.isConnectionOpen = NO;
    if(self.delegate != nil) {
        [self.delegate httpRequest:self onResponse:[[VDFHttpConnectorResponse alloc] initWithData:self.receivedData httpCode:self.lastResponseCode headers:self.responseHeaders]];
    }
}





@end

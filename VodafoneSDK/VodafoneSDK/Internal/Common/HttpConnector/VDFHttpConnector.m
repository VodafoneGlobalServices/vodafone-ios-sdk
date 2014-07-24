//
//  HttpRequest.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFHttpConnector.h"
#import "VDFError.h"

@interface VDFHttpConnector ()

@property (nonatomic, assign) id<VDFHttpConnectorDelegate> delegate;
@property (nonatomic, strong) NSMutableData *receivedData;

@end

@implementation VDFHttpConnector

@synthesize lastResponseCode = _lastResponseCode;

- (instancetype)initWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
        self.connectionTimeout = 60.0; // default if is not set from outside
        _lastResponseCode = 0;
    }
    return self;
}

- (void)get:(NSString*)url {
    NSURLRequest *request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                 timeoutInterval:self.connectionTimeout];
    
    // sending request:
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                            delegate:self];
    if(conn) {
        self.url = url;
        self.receivedData = [NSMutableData data];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        [self.delegate httpRequest:self onResponse:nil withError:error];
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
    [request setHTTPBody:body];
    
    // sending request:
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn) {
        self.url = url;
        self.receivedData = [NSMutableData data];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        [self.delegate httpRequest:self onResponse:nil withError:error];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    [self.receivedData setLength:0];
    _lastResponseCode = [(NSHTTPURLResponse*)response statusCode];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [self.receivedData appendData:data];
}


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSError *errorInVDFDomain = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
    [self.delegate httpRequest:self onResponse:nil withError:errorInVDFDomain];
}



- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    [self.delegate httpRequest:self onResponse:self.receivedData withError:nil];
}





@end

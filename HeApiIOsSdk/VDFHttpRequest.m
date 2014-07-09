//
//  HttpRequest.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFHttpRequest.h"
#import "VDFError.h"
#import "VDFStringHelper.h"

@interface VDFHttpRequest ()

@property (nonatomic, assign) id<VDFHttpRequestDelegate> delegate;
@property (nonatomic, strong) NSMutableData* receivedData;

@end

@implementation VDFHttpRequest

- (instancetype)initWithDelegate:(id<VDFHttpRequestDelegate>)delegate {
    self = [super init];
    if(self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)get:(NSString*)url {
    NSURLRequest *request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                     cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                 timeoutInterval:60.0];
    
    // wysłanie żądania:
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                            delegate:self];
    if(conn) {
        self.url = url;
        self.receivedData = [NSMutableData data];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        [self.delegate httpRequest:self errorOccurred:error];
    }
    
}

- (void)post:(NSString*)url withParams:(NSDictionary*)params
{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL: [NSURL URLWithString: url]
                            cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval: 60.0];
    
    request.HTTPMethod = @"POST";
    
    // parameters formatting:
    NSMutableString *paramsString = [NSMutableString string];
    if(params && params.count > 0) {
        int n = params.allKeys.count;
        for (int i=0; i<n; i++) {
            if(i != 0) {
                [paramsString appendString: @"&"];
            }
            
            NSString *key = params.allKeys[i];
            id object = [params objectForKey:key];
            NSString *val = [NSString stringWithFormat:@"%@", object];
            
            [paramsString appendFormat: @"%@=%@", key, [VDFStringHelper urlEncode:val]];
        }
    }
    
    NSData *data = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
    //[request addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    // sending request:
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn) {
        self.url = url;
        receivedData = [NSMutableData data];
    }
    else {
        NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
        [self.delegate httpRequest:self errorOccurred:error];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [receivedData appendData:data];
}


- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    NSError *error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:VDFErrorNoConnection userInfo:nil];
    [self.delegate httpRequest:self errorOccurred:error];
}



- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    [self.delegate httpRequest:self onResponse:receivedData];
}





@end

//
//  VDFRequestsManager.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFServiceRequestsManager.h"
#import "VDFBaseConfiguration.h"
#import "VDFHttpRequest.h"

@interface VDFServiceRequestsManager ()
@property (nonatomic, strong) VDFBaseConfiguration * configuration;
// key - id<VDFRequest> which starts the request, value - VDFHttpRequest
@property (nonatomic) NSMutableDictionary * pendingRequests;
// key - id<VDFRequest> which starts the request, value - NSMutableArray containing all id<VDFRequest>  waiting for response
@property (nonatomic) NSMutableDictionary * waitingResponses;

- (void)retrayRequest:(id<VDFRequest>)request;
@end

@implementation VDFServiceRequestsManager

- (id)initWithConfiguration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        self.configuration = configuration;
        self.pendingRequests = [NSMutableDictionary dictionary];
        self.waitingResponses = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)performRequest:(id<VDFRequest>)request {
    // TODO think about how to put on this stage the cache checking
    
    @synchronized(self.pendingRequests) {
        BOOL requestIsPending = NO;
        // check is there any the same request waiting for response
        for (id<VDFRequest> initialRequest in [self.waitingResponses allKeys]) {
            if([initialRequest isEqualToRequest:request]) {
                requestIsPending = YES;
                // registering this requests for waiting on response:
                NSMutableArray * requestsArray = [self.waitingResponses objectForKey:initialRequest];
                [requestsArray addObject:request];
                break;
            }
        }
        
        if(requestIsPending) {
            // creating new request
            VDFHttpRequest * httpRequest = [[VDFHttpRequest alloc] initWithDelegate:self];
            // and adding this to queue
            [self.pendingRequests setObject:httpRequest forKey:request];
            [self.waitingResponses setObject:[NSMutableArray arrayWithObject:request] forKey:request];
            
            // starting the request
            NSString * requestUrl = [self.configuration.endpointBaseUrl stringByAppendingString:[request urlEndpointMethod]];
            if([[request httpMethod] isEqualToString:@"POST"]) {
                [httpRequest post:requestUrl withParams:[request postParameters]];
            }
            else {
                [httpRequest get:requestUrl];
            }
        }
    }
}

#pragma mark -
#pragma mark private methods implementation

- (void)retrayRequest:(id<VDFRequest>)request {
    // TODO
    // make some http pooling
}

#pragma mark -
#pragma mark VDFServiceRequestsManager
- (void)httpRequest:(VDFHttpRequest*)request onResponse:(NSData*)data {
    @synchronized(self.pendingRequests) {
        // search for corresponding request:
        id<VDFRequest> correspondingRequest = nil;
        for (id<VDFRequest> pendingRequest in [self.pendingRequests allKeys]) {
            if([self.pendingRequests objectForKey:pendingRequest] == request) {
                correspondingRequest = pendingRequest;
                break;
            }
        }
        
        NSMutableArray * waitingForResponses = [self.waitingResponses objectForKey:correspondingRequest];
        if(waitingForResponses != nil) {
            // responding for all of them:
            for (id<VDFRequest> waitingRequest in waitingForResponses) {
                [waitingRequest onDataResponse:data];
            }
            
            // is it finished ?
            if([correspondingRequest isSatisfied]) {
                // remove this request from queue
                [self.pendingRequests removeObjectForKey:correspondingRequest];
                [self.waitingResponses removeObjectForKey:correspondingRequest];
            }
            else {
                // if not retry with http pooling
                [self retrayRequest:correspondingRequest];
            }
        }
    }
}

- (void)httpRequest:(VDFHttpRequest*)request errorOccurred:(NSError*)error {
    // TODO
}


@end

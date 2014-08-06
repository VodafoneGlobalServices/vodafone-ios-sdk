//
//  VDFRequestBaseFactory.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseFactory.h"
#import "VDFArrayObserversContainer.h"

@implementation VDFRequestBaseFactory

#pragma mark VDFRequestFactory as abstract methods

- (VDFHttpConnector*)createHttpConnectorRequestWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (VDFCacheObject*)createCacheObject {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (id<VDFResponseParser>)createResponseParser {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (id<VDFRequestState>)createRequestState {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

#pragma mark VDFRequestFactory base methods implementation

- (id<VDFObserversContainer>)createObserversContainer {
    return [[VDFArrayObserversContainer alloc] init];
}

@end

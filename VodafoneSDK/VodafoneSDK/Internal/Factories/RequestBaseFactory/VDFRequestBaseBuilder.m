//
//  VDFRequestBaseBuilder.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestBaseBuilder.h"
#import "VDFRequestFactory.h"
#import "VDFResponseParser.h"
#import "VDFRequestState.h"
#import "VDFObserversContainer.h"

@interface VDFRequestBaseBuilder ()
@property id<VDFResponseParser> internalResponseParser;
@property id<VDFRequestState> internalRequestState;
@property id<VDFObserversContainer> internalObserversContainer;
@end


@implementation VDFRequestBaseBuilder

- (instancetype)initWithApplicationId:(NSString*)applicationId diContainer:(VDFDIContainer*)diContainer {
    self = [super init];
    if(self) {
        self.applicationId = applicationId;
        self.diContainer = diContainer;
    }
    return self;
}

- (id<VDFRequestFactory>)factory {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}

- (id<VDFResponseParser>)responseParser {
    if(self.internalResponseParser == nil) {
        self.internalResponseParser = [[self factory] createResponseParser];
    }
    return self.internalResponseParser;
}

- (id<VDFRequestState>)requestState {
    if(self.internalRequestState == nil) {
        self.internalRequestState = [[self factory] createRequestState];
    }
    return self.internalRequestState;
}

- (id<VDFObserversContainer>)observersContainer {
    if(self.internalObserversContainer == nil) {
        self.internalObserversContainer = [[self factory] createObserversContainer];
    }
    return self.internalObserversContainer;
}

- (VDFHttpConnector*)createCurrentHttpConnectorWithDelegate:(id<VDFHttpConnectorDelegate>)delegate {
    return [[self factory] createHttpConnectorRequestWithDelegate:delegate];
}

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}


@end

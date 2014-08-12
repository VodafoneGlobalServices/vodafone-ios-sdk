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
@property id<VDFRequestFactory> internalFactory;
@property id<VDFResponseParser> internalResponseParser;
@property id<VDFRequestState> internalRequestState;
@property id<VDFObserversContainer> internalObserversContainer;
@end


@implementation VDFRequestBaseBuilder

- (instancetype)initWithFactory:(id<VDFRequestFactory>)factory applicationId:(NSString*)applicationId configuration:(VDFBaseConfiguration*)configuration {
    self = [super init];
    if(self) {
        self.applicationId = applicationId;
        self.configuration = configuration;
        self.internalFactory = factory;
    }
    return self;
}

- (id<VDFRequestFactory>)factory {
    return self.internalFactory;
}

- (id<VDFResponseParser>)responseParser {
    if(self.internalResponseParser == nil) {
        self.internalResponseParser = [self.internalFactory createResponseParser];
    }
    return self.internalResponseParser;
}

- (id<VDFRequestState>)requestState {
    if(self.internalRequestState == nil) {
        self.internalRequestState = [self.internalFactory createRequestState];
    }
    return self.internalRequestState;
}

- (id<VDFObserversContainer>)observersContainer {
    if(self.internalObserversContainer == nil) {
        self.internalObserversContainer = [self.internalFactory createObserversContainer];
    }
    return self.internalObserversContainer;
}

- (BOOL)isEqualToFactoryBuilder:(id<VDFRequestBuilder>)builder {
    [self doesNotRecognizeSelector:_cmd];
    __builtin_unreachable();
}


@end

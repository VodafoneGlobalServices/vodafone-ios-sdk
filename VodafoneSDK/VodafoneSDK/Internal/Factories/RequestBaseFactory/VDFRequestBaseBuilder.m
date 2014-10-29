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
#import "VDFBaseConfiguration.h"
#import "VDFDIContainer.h"

static NSString * const DESCRIPTION_FORMAT = @"clientAppKey:%@\n\t backendAppKey:%@";

@interface VDFRequestBaseBuilder ()
@property id<VDFResponseParser> internalResponseParser;
@property id<VDFRequestState> internalRequestState;
@property id<VDFObserversContainer> internalObserversContainer;
@end

@implementation VDFRequestBaseBuilder

- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer {
    self = [super init];
    if(self) {
        VDFBaseConfiguration *configuration = [diContainer resolveForClass:[VDFBaseConfiguration class]];
        self.clientAppKey = configuration.clientAppKey;
        self.clientAppSecret = configuration.clientAppSecret;
        self.backendAppKey = configuration.backendAppKey;
        self.diContainer = diContainer;
    }
    return self;
}

-(NSString*)keyType {
    return NSStringFromClass([self class]);
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

- (NSString*)description {
    return [NSString stringWithFormat: DESCRIPTION_FORMAT, self.clientAppKey, self.backendAppKey];
}

@end

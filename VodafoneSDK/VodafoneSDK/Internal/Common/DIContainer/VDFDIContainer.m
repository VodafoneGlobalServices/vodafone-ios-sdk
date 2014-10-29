//
//  VDFDIContainer.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 28/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFDIContainer.h"

@interface VDFDIContainer ()
@property (nonatomic, strong) NSMutableDictionary *instancesByClassType;
@property (nonatomic, strong) NSMutableDictionary *instancesByProtocolType;
@end

@implementation VDFDIContainer

- (instancetype)init {
    self = [super init];
    if(self) {
        self.instancesByClassType = [[NSMutableDictionary alloc] init];
        self.instancesByProtocolType = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerInstance:(id)instance forClass:(Class)classType {
    if(instance == nil) {
        [self.instancesByClassType removeObjectForKey:NSStringFromClass(classType)];
    }
    else {
        [self.instancesByClassType setValue:instance forKey:NSStringFromClass(classType)];
    }
}

- (void)registerInstance:(id)instance forProtocol:(Protocol*)protocolType {
    if(instance == nil) {
        [self.instancesByProtocolType removeObjectForKey:NSStringFromProtocol(protocolType)];
    }
    else {
        [self.instancesByProtocolType setValue:instance forKey:NSStringFromProtocol(protocolType)];
    }
}

- (id)resolveForClass:(Class)classType {
    return [self.instancesByClassType valueForKey:NSStringFromClass(classType)];
}

- (id)resolveForProtocol:(Protocol*)protocolType {
    return [self.instancesByProtocolType valueForKey:NSStringFromProtocol(protocolType)];
}


@end

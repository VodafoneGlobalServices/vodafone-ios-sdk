//
//  VDFArrayObserverContainerItem.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFArrayObserverContainerItem.h"

@implementation VDFArrayObserverContainerItem

- (instancetype)initWithPriority:(NSInteger)priority observer:(id)observer {
    self = [super init];
    if(self) {
        self.invokePriority = priority;
        self.observer = observer;
    }
    return self;
}

- (NSComparisonResult)compare:(VDFArrayObserverContainerItem*)item {
    if(item != nil) {
        if(self.invokePriority > item.invokePriority) {
            return NSOrderedAscending;
        }
        if(self.invokePriority < item.invokePriority) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }
    return NSOrderedAscending;
}

@end

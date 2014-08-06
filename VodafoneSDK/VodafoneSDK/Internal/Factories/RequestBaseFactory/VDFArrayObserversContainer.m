//
//  VDFArrayObserversContainer.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFArrayObserversContainer.h"

@interface VDFArrayObserversContainer ()
@property SEL notifySelector;
@property NSMutableArray *observers;
@end

@implementation VDFArrayObserversContainer

- (instancetype)init {
    self = [super init];
    if(self) {
        self.observers = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark VDFObserversContainer Protocol Implementation

- (void)setObserversNotifySelector:(SEL)selector {
    self.notifySelector = selector;
}

- (void)registerObserver:(id)observer {
    if(observer != nil && ![self.observers containsObject:observer]) {
        [self.observers addObject:observer];
    }
}

- (void)unregisterObserver:(id)observer {
    [self.observers removeObject:observer];
}

- (void)notifyAllObserversWith:(id)object error:(NSError*)error {
    if(self.notifySelector == nil) {
        return; // if selector is not set, then we need to stop
    }
    
    for (id observer in self.observers) {
        if([observer respondsToSelector:self.notifySelector]) {
            // invoke delegate with response on the main thread:
            if([NSThread isMainThread]) {
                [observer performSelector:self.notifySelector withObject:object withObject:error];
            }
            else {
                // we are on some different thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer performSelector:self.notifySelector withObject:object withObject:error];
                });
            }
        }
    }
}

- (NSUInteger)count {
    return [self.observers count];
}

@end

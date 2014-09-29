//
//  VDFArrayObserversContainer.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFArrayObserversContainer.h"
#import "VDFArrayObserverContainerItem.h"

@interface VDFArrayObserversContainer ()
@property SEL notifySelector;
@property NSMutableArray *observers;

- (VDFArrayObserverContainerItem*)findItemForObserver:(id)observer;
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

- (NSArray*)registeredObservers {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self.observers count]];
    NSArray *sortedItems = [self.observers sortedArrayUsingSelector:@selector(compare:)];
    for (VDFArrayObserverContainerItem *item in sortedItems) {
        [result addObject:item.observer];
    }
    return result;
}

- (void)setObserversNotifySelector:(SEL)selector {
    self.notifySelector = selector;
}

- (void)registerObserver:(id)observer {
    [self registerObserver:observer withPriority:0];
}

- (void)registerObserver:(id)observer withPriority:(NSInteger)priority {
    // TODO if observer exisiting, update it position (Ya Aint Need It?)
    if(observer != nil && [self findItemForObserver:observer] == nil) {
        [self.observers addObject:[[VDFArrayObserverContainerItem alloc] initWithPriority:priority observer:observer]];
    }
}

- (void)unregisterObserver:(id)observer {
    VDFArrayObserverContainerItem *item = [self findItemForObserver:observer];
    [self.observers removeObject:item];
}

- (void)notifyAllObserversWith:(id)object error:(NSError*)error {
    if(self.notifySelector == nil) {
        return; // if selector is not set, then we need to stop
    }
    
    for (id observer in [self registeredObservers]) {
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

#pragma mark -
#pragma mark - PRivate methods implementation

- (VDFArrayObserverContainerItem*)findItemForObserver:(id)observer {
    for (VDFArrayObserverContainerItem *item in self.observers) {
        if(item.observer == observer) {
            return item;
        }
    }
    return nil;
}

@end

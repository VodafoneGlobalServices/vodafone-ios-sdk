//
//  VDFRequestCallsCounter.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 05/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFRequestCallsCounter.h"
#import "VDFDIContainer.h"
#import "VDFBaseConfiguration.h"

@interface VDFRequestCallsCounter ()
@property (nonatomic, strong) VDFDIContainer *diContainer;
@property (nonatomic, strong) NSMutableDictionary *callsListPerClassType;
@end

@implementation VDFRequestCallsCounter

- (instancetype)initWithDIContainer:(VDFDIContainer*)diContainer {
    self = [super init];
    if(self) {
        self.diContainer = diContainer;
        self.callsListPerClassType = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)incrementCallType:(Class)classType {
    NSMutableArray *callDates = [self.callsListPerClassType objectForKey:NSStringFromClass(classType)];
    if(callDates == nil) {
        // create new list for this request type
        callDates = [[NSMutableArray alloc] init];
        [self.callsListPerClassType setValue:callDates forKey:NSStringFromClass(classType)];
    }
    
    [callDates addObject:[NSDate date]];
}

- (BOOL)canPerformRequestOfType:(Class)classType {
    
    BOOL result = YES;
    NSMutableArray *callDates = [self.callsListPerClassType objectForKey:NSStringFromClass(classType)];
    if(callDates != nil) {
        VDFBaseConfiguration *configuration = [self.diContainer resolveForClass:[VDFBaseConfiguration class]];
        // iterate over all dates from list and remove this expired:
        NSMutableArray *datesToRemove = [[NSMutableArray alloc] init];
        for (NSDate *date in callDates) {
            if([date timeIntervalSinceNow] > configuration.requestsThrottlingPeriod) {
                [datesToRemove addObject:date];
            }
        }
        
        [callDates removeObjectsInArray:datesToRemove];
        
        result = [callDates count] < configuration.requestsThrottlingLimit;
    }
    
    return result;
}

@end

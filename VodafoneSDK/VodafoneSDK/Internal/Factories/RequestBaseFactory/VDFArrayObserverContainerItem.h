//
//  VDFArrayObserverContainerItem.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/09/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFArrayObserverContainerItem : NSObject
@property (nonatomic, assign) NSInteger invokePriority;
@property (nonatomic, strong) id observer;

- (instancetype)initWithPriority:(NSInteger)priority observer:(id)observer;

- (NSComparisonResult)compare:(VDFArrayObserverContainerItem*)item;
@end

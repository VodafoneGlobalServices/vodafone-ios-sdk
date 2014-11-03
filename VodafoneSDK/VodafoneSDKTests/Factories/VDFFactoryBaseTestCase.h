//
//  VDFFactoryBaseTestCase.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VDFArrayObserversContainer.h"
#import "VDFHttpConnector.h"
#import "VDFTestCase.h"

@interface VDFHttpConnector ()
@property (nonatomic, assign) id<VDFHttpConnectorDelegate> delegate;
@end

@interface VDFArrayObserversContainer ()
@property SEL notifySelector;
@property NSMutableArray *observers;
@end

@interface VDFFactoryBaseTestCase : VDFTestCase

- (id)runAndAssertSimpleCreateMethodOnTarget:(id)target selector:(SEL)selector expectedResultClass:(Class)expectedResultClass;

@end

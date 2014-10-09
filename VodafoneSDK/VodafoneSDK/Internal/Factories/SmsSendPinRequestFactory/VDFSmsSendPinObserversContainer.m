//
//  VDFSmsSendPinObserversContainer.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 09/10/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsSendPinObserversContainer.h"

@implementation VDFSmsSendPinObserversContainer

- (void)notifyAllObserversWith:(id)object error:(NSError*)error {
    if(error != nil) {
        // when some error occure then result is always NSNumber set to NO
        [super notifyAllObserversWith:@NO error:error];
    }
    else {
        [super notifyAllObserversWith:object error:error];
    }
}
@end

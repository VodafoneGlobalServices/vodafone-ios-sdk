//
//  VDFErrorUtility.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VDFErrorUtility : NSObject

+ (BOOL)handleInternalError:(NSError*)error;

@end

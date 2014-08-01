//
//  VDFErrorUtility.h
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 09/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Error handling helper class
 */
@interface VDFErrorUtility : NSObject

/**
 *  Checks is this critical error. Logs for debug all errors.
 *
 *  @param error Errow which has occured.
 *
 *  @return YES - if it was handled, NO - if need to be handled outside
 */
+ (BOOL)handleInternalError:(NSError*)error;

@end

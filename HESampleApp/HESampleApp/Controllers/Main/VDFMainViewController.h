//
//  VDFMainViewController.h
//  HESampleApp
//
//  Created by Michał Szymańczyk on 14/07/14.
//  Copyright (c) 2014 Vodafone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <VodafoneSDK/VodafoneSDK.h>


/**
 *  Log message type
 */
typedef NS_ENUM(NSUInteger, VDFLogType) {
    /**
     *  Message is used for debug.
     */
    VDFLogDebugType = 0,
    /**
     *  Message is used for information.
     */
    VDFLogInfoType,
};


@interface VDFMainViewController : UIViewController <VDFUsersServiceDelegate, MFMailComposeViewControllerDelegate>

@end

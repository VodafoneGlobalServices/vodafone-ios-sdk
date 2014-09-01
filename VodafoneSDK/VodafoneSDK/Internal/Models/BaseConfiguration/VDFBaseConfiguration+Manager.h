//
//  VDFBaseConfiguration_Manager.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 29/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFBaseConfiguration.h"

/**
 *  Extension of base configuration class for configuration manager.
 */
@interface VDFBaseConfiguration ()

/**
 *  Date of last configuration update
 */
@property (nonatomic, strong) NSDate *configurationLastUpdateDate;

/**
 *  Time interval (in seconds) for how long current configuration is valid.
 */
@property (nonatomic, assign) NSTimeInterval configurationValidityTimeSpan;

/**
 *  Etag returned from last configuration update
 */
@property (nonatomic, strong) NSString *configurationUpdateEtag;

@end

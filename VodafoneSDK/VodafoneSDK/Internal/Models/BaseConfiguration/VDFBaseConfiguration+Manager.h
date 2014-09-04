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
@property (nonatomic, strong) NSDate *configurationLastModifiedDate;

/**
 *  Time interval (in seconds) for how long current configuration need to be cheked for updates.
 */
@property (nonatomic, assign) NSTimeInterval configurationUpdateCheckTimeSpan;

/**
 *  Etag returned from last configuration update
 */
@property (nonatomic, strong) NSString *configurationUpdateEtag;

/**
 *  Updates current configuration object with parsed json object.
 *
 *  @param jsonObjectDictionary Json object dictionary containing parameters to update.
 */
- (void)updateWithJson:(NSDictionary*)jsonObjectDictionary;

@end
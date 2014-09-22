//
//  VDFDeviceUtility.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Utility class for retireval information about device
 */
@interface VDFDeviceUtility : NSObject

/**
 *  Reads unique identifier of the device.
 *
 *  @return NSString describing unique identifier of device.
 */
+ (NSString*)deviceUniqueIdentifier;

/**
 *  Reads from sim card, mobile country code.
 *
 *  @return An NSString containing the mobile country code for the subscriber's
 *   cellular service provider, in its numeric representation.
 *      The value for this property is nil if any of the following apply:
 *      There is no SIM card in the device.
 *      The device is outside of cellular service range.
 *      The value may be nil on hardware prior to iPhone 4S when in Airplane mode.
 */
+ (NSString*)simMCC;

/**
 *  Reads from sim card, mobile country code and mobile network code.
 *
 *  @return An NSString containing the mobile country and network code for the subscriber's
 *   cellular service provider, in its numeric representation.
 *      The value for this property is nil if any of the following apply:
 *      There is no SIM card in the device.
 *      The device is outside of cellular service range.
 *      The value may be nil on hardware prior to iPhone 4S when in Airplane mode.
 */
+ (NSString*)simMccMnc;

/**
 *  Compare mcc included in msisdn to available market codes.
 *
 *  @param msisdn           MSISDN with mobice country code and phone number without leading 00 and +
 *  @param markets Dictionary with markets (e.g @{ @"DE": 49, ... } )
 *
 *  @return Market code (e.g. "DE") or nil if msisdn is wrong or mcc from msisdn is not avaialble in markets dictionary
 */
+ (NSString*)findMarketForMsisdn:(NSString*)msisdn inMarkets:(NSDictionary*)markets;


@end

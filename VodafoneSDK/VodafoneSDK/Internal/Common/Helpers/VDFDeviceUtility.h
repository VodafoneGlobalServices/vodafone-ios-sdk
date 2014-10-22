//
//  VDFDeviceUtility.h
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Network avaialblity status enum
 */
typedef NS_ENUM(NSUInteger, VDFNetworkAvailability) {
    /**
     *  Network is not available.
     */
    VDFNetworkNotAvailable = 0,
    /**
     *  Network is avaiable and it is WiFi.
     */
    VDFNetworkAvailableViaWiFi,
    /**
     *  Network is avaialble and it is GSM.
     */
    VDFNetworkAvailableViaGSM,
};

/**
 *  Utility class for retireval information about device
 */
@interface VDFDeviceUtility : NSObject

/**
 *  Reads unique identifier of the device.
 *
 *  @return NSString describing unique identifier of device.
 */
- (NSString*)deviceUniqueIdentifier;

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
- (NSString*)simMccMnc;

/**
 *  Compare mcc included in msisdn to available market codes.
 *
 *  @param msisdn           MSISDN with mobice country code and phone number without leading 00 and +
 *  @param markets Dictionary with markets (e.g @{ @"DE": 49, ... } )
 *
 *  @return Market code (e.g. "DE") or nil if msisdn is wrong or mcc from msisdn is not avaialble in markets dictionary
 */
- (NSString*)findMarketForMsisdn:(NSString*)msisdn inMarkets:(NSDictionary*)markets;

/**
 *  Check type of network with wich device is connected.
 *
 *  @return Type of network wich is available.
 */
- (VDFNetworkAvailability)checkNetworkTypeAvailability;

/**
 *  OS name.
 *
 *  @return String representig installed device OS, e.g. "iOS 8.0".
 */
- (NSString*)osName;

/**
 *  Device hardware name.
 *
 *  @return Device hardware name.
 */
- (NSString*)deviceHardwareName;

@end

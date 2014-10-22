//
//  VDFDeviceUtility.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFDeviceUtility.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "VDFNetworkReachability.h"
#import <sys/utsname.h>

@implementation VDFDeviceUtility

- (NSString*)deviceUniqueIdentifier {
    // http://stackoverflow.com/questions/19606773/always-get-a-unique-device-id-in-ios-7
    // if not wirking check the link above
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString*)simMCC {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return [carrier mobileCountryCode];
}

- (NSString*)simMccMnc {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    if(mcc != nil && mnc != nil) {
        return [mcc stringByAppendingString:mnc];
    }
    return nil;
}

- (NSString*)findMarketForMsisdn:(NSString*)msisdn inMarkets:(NSDictionary*)markets {

    NSArray *sortedKeys = [markets keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if([obj1 intValue] == [obj2 intValue]) {
            return NSOrderedSame;
        }
        return [obj1 intValue] > [obj2 intValue] ? NSOrderedAscending:NSOrderedDescending; // sorting from max to min
    }];

    for (NSString *key in sortedKeys) {
        NSNumber *value = [markets objectForKey:key];
        if([msisdn hasPrefix:[value stringValue]]) {
            return key;
        }
    }
    return nil;
}

- (VDFNetworkAvailability)checkNetworkTypeAvailability {
    VDFNetworkReachability *reachability = [VDFNetworkReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus currentNetworkStatus = [reachability currentReachabilityStatus];
    if(currentNetworkStatus == NotReachable) {
        return VDFNetworkNotAvailable;
    }
    if(currentNetworkStatus == ReachableViaWiFi) {
        return VDFNetworkAvailableViaWiFi;
    }
    return VDFNetworkAvailableViaGSM;
}

- (NSString*)osName {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return [NSString stringWithFormat: @"%@ %@", [currentDevice systemName], [currentDevice systemVersion]];
}

- (NSString*)deviceHardwareName {
    
    NSString *result = nil;
    
    @try {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        result = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        result = [NSString string];
    }
    
    return result;
}
@end

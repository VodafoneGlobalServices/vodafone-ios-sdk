//
//  VDFSmsSendPinResponseParser.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsSendPinResponseParser.h"
#import "VDFHttpConnectorResponse.h"

static NSInteger const SuccessResponseCode = 200;

@implementation VDFSmsSendPinResponseParser

- (id)parseResponse:(VDFHttpConnectorResponse*)response {
    if(response != nil) {
        return [NSNumber numberWithBool:response.httpResponseCode == SuccessResponseCode];
    }
    return nil;
}

@end

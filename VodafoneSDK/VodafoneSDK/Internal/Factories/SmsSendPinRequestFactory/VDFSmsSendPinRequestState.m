//
//  VDFSmsSendPinRequestState.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 20/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFSmsSendPinRequestState.h"
#import "VDFHttpConnectorResponse.h"
#import "VDFError.h"
#import "VDFRequestState.h"

@interface VDFSmsSendPinRequestState ()
@property (nonatomic, strong) NSError *error;
@end

@implementation VDFSmsSendPinRequestState

- (void)updateWithHttpResponse:(VDFHttpConnectorResponse*)response {
    if(response != nil && response.httpResponseCode != 200) {
        NSInteger errorCode = VDFErrorServerCommunication;
        if(response.httpResponseCode == 400) {
            errorCode = VDFErrorInvalidInput;
        }
        if(response.httpResponseCode == 404) {
            errorCode = VDFErrorResolutionTimeout;
        }
        // TODO obslugcy 403
        self.error = [[NSError alloc] initWithDomain:VodafoneErrorDomain code:errorCode userInfo:nil];
    }
}

- (NSError*)responseError {
    return self.error;
}

@end

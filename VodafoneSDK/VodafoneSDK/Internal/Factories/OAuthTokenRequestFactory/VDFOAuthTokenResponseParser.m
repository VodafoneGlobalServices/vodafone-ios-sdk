//
//  VDFOAuthTokenResponseParser.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenResponseParser.h"
#import "VDFOAuthTokenResponse.h"
#import "VDFErrorUtility.h"
#import "VDFLogUtility.h"
#import "VDFHttpConnectorResponse.h"

@implementation VDFOAuthTokenResponseParser

- (id<NSCoding>)parseResponse:(VDFHttpConnectorResponse*)response {
    
    VDFOAuthTokenResponse *oAuthToken = nil;
    if(response !=nil && response.data != nil && response.httpResponseCode == 200) {
        VDFLogD(@"Parsing response VDFOAuthTokenResponse");
        
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:&error];
        BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
        
        if(![VDFErrorUtility handleInternalError:error] && isResponseValid) {
            // object parsed correctlly
            oAuthToken = [[VDFOAuthTokenResponse alloc] initWithJsonObject:jsonObject];
        }
        VDFLogD(@"Parsed object: \n%@", oAuthToken);
    }
    return oAuthToken;
}

@end

//
//  VDFUserResolveResponseParser.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 04/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserResolveResponseParser.h"
#import "VDFUserTokenDetails.h"
#import "VDFLogUtility.h"
#import "VDFErrorUtility.h"
#import "VDFHttpConnectorResponse.h"

@implementation VDFUserResolveResponseParser

- (id<NSCoding>)parseResponse:(VDFHttpConnectorResponse*)response {
    
    VDFUserTokenDetails* userTokenDetails = nil;
    if(response != nil && response.data != nil && response.httpResponseCode == 200) {
        
        VDFLogD(@"Parsing response: %@", response.data);
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:&error];
        BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
        
        if([VDFErrorUtility handleInternalError:error] || !isResponseValid) {
            // handle error here
            // TODO
        }
        else {
            // object parsed correctlly
            userTokenDetails = [[VDFUserTokenDetails alloc] initWithJsonObject:jsonObject];
        }
        VDFLogD(@"Parsed object: \n%@", userTokenDetails);
    }
    
    return userTokenDetails;
}

@end

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

@implementation VDFOAuthTokenResponseParser

- (id<NSCoding>)parseData:(NSData*)data withHttpResponseCode:(NSInteger)responseCode {
    
    VDFOAuthTokenResponse *oAuthToken = nil;
    if(data != nil && responseCode == 200) {
        VDFLogD(@"Parsing response VDFOAuthTokenResponse");
        
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
        
        if([VDFErrorUtility handleInternalError:error] || !isResponseValid) {
            // handle error here
            // TODO
        }
        else {
            // object parsed correctlly
            oAuthToken = [[VDFOAuthTokenResponse alloc] initWithJsonObject:jsonObject];
        }
        VDFLogD(@"Parsed object: \n%@", oAuthToken);

    }
    
    return oAuthToken;
}

@end

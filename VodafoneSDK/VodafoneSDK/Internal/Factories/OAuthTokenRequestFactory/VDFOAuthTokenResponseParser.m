//
//  VDFOAuthTokenResponseParser.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 11/08/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFOAuthTokenResponseParser.h"

@implementation VDFOAuthTokenResponseParser

- (id<NSCoding>)parseData:(NSData*)data withHttpResponseCode:(NSInteger)responseCode {
    
//    VDFUserTokenDetails* userTokenDetails = nil;
//    if(data != nil) {
//        
//        VDFLogD(@"Parsing response: %@", data);
//        NSError *error = nil;
//        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//        BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
//        
//        if([VDFErrorUtility handleInternalError:error] || !isResponseValid) {
//            // handle error here
//            // TODO
//        }
//        else {
//            // object parsed correctlly
//            userTokenDetails = [[VDFUserTokenDetails alloc] initWithJsonObject:jsonObject];
//        }
//        VDFLogD(@"Parsed object: \n%@", userTokenDetails);
//    }
//    
//    return userTokenDetails;
    
    return nil; // TODO
}

@end

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

@implementation VDFUserResolveResponseParser

- (id<NSCoding>)parseData:(NSData*)data withHttpResponseCode:(NSInteger)responseCode {
    VDFLogD(@"Parsing response: %@", data);
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    BOOL isResponseValid = [jsonObject isKindOfClass:[NSDictionary class]];
    VDFUserTokenDetails* userTokenDetails = nil;
    
    if([VDFErrorUtility handleInternalError:error] || !isResponseValid) {
        // handle error here
        // TODO
    }
    else {
        // object parsed correctlly
        userTokenDetails = [[VDFUserTokenDetails alloc] initWithJsonObject:jsonObject];
    }
    VDFLogD(@"Parsed object: \n%@", userTokenDetails);
    
    return userTokenDetails;
}

@end

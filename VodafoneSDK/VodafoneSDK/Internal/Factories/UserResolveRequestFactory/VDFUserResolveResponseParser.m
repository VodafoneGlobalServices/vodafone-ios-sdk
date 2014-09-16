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
#import "VDFConsts.h"

@implementation VDFUserResolveResponseParser

- (id<NSCoding>)parseResponse:(VDFHttpConnectorResponse*)response {
    
    if(response == nil) {
        return nil;
    }
    
    VDFUserTokenDetails* userTokenDetails = nil;
    if(response.httpResponseCode == 201) {
        // read ACR, expires in, tokenID from body
        if(response.data != nil) {
            
            VDFLogD(@"Parsing response: %@", response.data);
            id jsonObject = [NSJSONSerialization JSONObjectWithData:response.data options:kNilOptions error:nil];
            
            if(jsonObject != nil && [jsonObject isKindOfClass:[NSDictionary class]]) {
                // object parsed correctlly
                userTokenDetails = [[VDFUserTokenDetails alloc] init];
                userTokenDetails.stillRunning = NO;
                userTokenDetails.resolved = YES;
                userTokenDetails.token = [jsonObject objectForKey:@"token"];
                id expiresInObject = [jsonObject objectForKey:@"expiresIn"];
                if(expiresInObject != nil) {
                    userTokenDetails.expiresIn = [NSDate dateWithTimeIntervalSinceNow:[expiresInObject intValue]];
                }
            }
            VDFLogD(@"Parsed object: \n%@", userTokenDetails);
        }
    }
    else if(response.httpResponseCode == 404) {
        userTokenDetails = [[VDFUserTokenDetails alloc] init];
        userTokenDetails.stillRunning = NO;
        userTokenDetails.resolved = NO;
    }
    else if(response.httpResponseCode == 302) {
        
        // TODO if it is first response of check status we should not inform delegates so we need to not parse it
        
        userTokenDetails = [[VDFUserTokenDetails alloc] init];
        userTokenDetails.stillRunning = YES;
        userTokenDetails.resolved = NO;
        
        // try to parse the location header
        NSString *location = [response.responseHeaders objectForKey:HTTP_HEADER_LOCATION];
        if(location != nil) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/users/tokens/([^?/]+)[?/]" options:NSRegularExpressionCaseInsensitive error:nil];
            
            NSArray *matches = [regex matchesInString:location options:0 range:NSMakeRange(0, [location length])];
            NSTextCheckingResult *match = [matches objectAtIndex:0];
            
            if(match != nil) {
                userTokenDetails.token = [location substringWithRange:NSMakeRange(match.range.location+14, match.range.length-15)];
            }
            
            if([location rangeOfString:@"/pins?backendId="].location != NSNotFound) {
                userTokenDetails.validationRequired = YES;
            }
        }
    }
    
    return userTokenDetails;
}

@end

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

@interface VDFUserResolveResponseParser ()
@property (nonatomic, strong) NSString *last302LocationHeader;
@property (nonatomic, strong) NSString *lastResponseEtagHeader;
@end

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
                userTokenDetails.resolutionStatus = VDFResolutionStatusCompleted;
                userTokenDetails.acr = [jsonObject objectForKey:@"acr"];
                userTokenDetails.token = [jsonObject objectForKey:@"tokenId"];
                id expiresInObject = [jsonObject objectForKey:@"expiresIn"];
                if(expiresInObject != nil) {
                    userTokenDetails.expiresIn = [NSDate dateWithTimeIntervalSinceNow:[expiresInObject intValue]/1000.0];
                }
            }
            VDFLogD(@"Parsed object: \n%@", userTokenDetails);
        }
    }
    else if(response.httpResponseCode == 404) {
        userTokenDetails = [[VDFUserTokenDetails alloc] init];
        userTokenDetails.resolutionStatus = VDFResolutionStatusFailed;
    }
    else if(response.httpResponseCode == 302) {
        
        NSString *locationHeader = [response.responseHeaders objectForKey:HTTP_HEADER_LOCATION];
        NSString *eTagHeader = [response.responseHeaders objectForKey:HTTP_HEADER_ETAG];
        
        // if it is first response of check status we should not inform delegates so we need to not parse it
        
        // so we parse the response when, it is first redirect (from resolve)
        BOOL parseResponse = self.last302LocationHeader == nil && self.lastResponseEtagHeader == nil;
        // or when location header has changed
        parseResponse = parseResponse || ![self.last302LocationHeader isEqualToString:locationHeader];
        // or etag value has changed
        parseResponse = parseResponse || (self.lastResponseEtagHeader != nil && ![self.lastResponseEtagHeader isEqualToString:eTagHeader]);
        
        if(parseResponse) {
        
            userTokenDetails = [[VDFUserTokenDetails alloc] init];
            
            userTokenDetails.resolutionStatus = VDFResolutionStatusPending;
            
            // try to parse the location header
            if(locationHeader != nil) {
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/users/tokens/([^?/]+)[?/]" options:NSRegularExpressionCaseInsensitive error:nil];
                
                NSArray *matches = [regex matchesInString:locationHeader options:0 range:NSMakeRange(0, [locationHeader length])];
                NSTextCheckingResult *match = [matches objectAtIndex:0];
                
                if(match != nil) {
                    userTokenDetails.token = [locationHeader substringWithRange:NSMakeRange(match.range.location+14, match.range.length-15)];
                }
                
                if([locationHeader rangeOfString:@"/pins?backendId="].location != NSNotFound) {
                    userTokenDetails.resolutionStatus = VDFResolutionStatusValidationRequired;
                }
            }
        }
        
        self.last302LocationHeader = locationHeader;
        self.lastResponseEtagHeader = eTagHeader;
    }
    
    if(response.httpResponseCode != 302) {
        self.last302LocationHeader = nil;
        self.lastResponseEtagHeader = nil;
    }
    
    return userTokenDetails;
}

@end

//
//  VDFUserTokenDetails.m
//  HeApiIOsSdk
//
//  Created by Michał Szymańczyk on 08/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import "VDFUserTokenDetails.h"
#import "VDFUserTokenDetails+Internal.h"

static NSString * const ResolutionStatusKey = @"resolutionStatus";
static NSString * const TokenKey = @"tokenId";
static NSString * const ExpiresInKey = @"expiresIn";
static NSString * const ACRKey = @"acr";

@implementation VDFUserTokenDetails

- (NSString*)description {
    return [NSString stringWithFormat:@"VDFUserTokenDetails { resolutionStatus=%@, token=%@, expiresIn=%@, acr=%@ }",
            [self resolutionStatusString], self.token, self. expiresIn, self.acr];
}

- (NSString*)resolutionStatusString {
    switch (self.resolutionStatus) {
        case VDFResolutionStatusCompleted: return @"VDFResolutionStatusCompleted";
        case VDFResolutionStatusUnableToResolve: return @"VDFResolutionStatusUnableToResolve";
        case VDFResolutionStatusValidationRequired: return @"VDFResolutionStatusValidationRequired";
            
        default:
            break;
    }
    return nil;
}

#pragma mark -
#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder*)decoder {
    self = [super init];
    if(self) {
        _resolutionStatus = [decoder decodeIntForKey:ResolutionStatusKey];
        _token = [decoder decodeObjectForKey:TokenKey];
        _expiresIn = [decoder decodeObjectForKey:ExpiresInKey];
        _acr = [decoder decodeObjectForKey:ACRKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeInt:_resolutionStatus forKey:ResolutionStatusKey];
    [encoder encodeObject:_token forKey:TokenKey];
    [encoder encodeObject:_expiresIn forKey:ExpiresInKey];
    [encoder encodeObject:_acr forKey:ACRKey];
}

@end

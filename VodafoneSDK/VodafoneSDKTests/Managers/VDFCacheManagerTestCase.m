//
//  VDFCacheManagerTestCase.m
//  VodafoneSDK
//
//  Created by Michał Szymańczyk on 25/07/14.
//  Copyright (c) 2014 VOD. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VDFCacheManager.h"
#import "VDFBaseConfiguration.h"
#import "VDFDIContainer.h"
#import "VDFCacheObject.h"

extern void __gcov_flush();

@interface VDFCacheManager ()
@property (nonatomic, strong) NSMutableArray *cacheObjects;

- (VDFCacheObject*)findInInternalCache:(NSString*)cacheKey;
@end

@interface VDFCacheManagerTestCase : XCTestCase
@property VDFCacheManager *managerToTest;
@property id mockCacheObjectsArray;
@end

@implementation VDFCacheManagerTestCase


- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.managerToTest = [[VDFCacheManager alloc] init];
    
    NSDate *expDate = [NSDate dateWithTimeIntervalSinceNow:3600];
    NSMutableArray *cacheObjects = [NSMutableArray arrayWithArray:
                                    @[[[VDFCacheObject alloc] initWithValue:@"someVal1" forKey:@"someKey1" withExpirationDate:expDate],
                                      [[VDFCacheObject alloc] initWithValue:@"someVal2" forKey:@"someKey2" withExpirationDate:expDate],
                                      [[VDFCacheObject alloc] initWithValue:@"someVal3" forKey:@"someKey3" withExpirationDate:expDate],
                                      [[VDFCacheObject alloc] initWithValue:@"someVal4" forKey:@"someKey4" withExpirationDate:expDate],
                                      [[VDFCacheObject alloc] initWithValue:@"someVal5" forKey:@"someKey5" withExpirationDate:expDate],
                                      [[VDFCacheObject alloc] initWithValue:@"someVal6" forKey:@"someKey6" withExpirationDate:expDate]]];
    self.mockCacheObjectsArray = OCMPartialMock(cacheObjects);
    self.managerToTest.cacheObjects = self.mockCacheObjectsArray;
}

- (void)tearDown
{
    __gcov_flush();
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsObjectCachedWhenNotCached {
    
    // mock
    VDFCacheObject *cacheObject = [[VDFCacheObject alloc] initWithValue:nil forKey:@"someNonExistingKey" withExpirationDate:nil];
    VDFCacheObject *cacheObjectWithNilKey = [[VDFCacheObject alloc] initWithValue:nil forKey:nil withExpirationDate:nil];
    
    // run & assert
    XCTAssertFalse([self.managerToTest isObjectCached:nil], @"Nil object cannot be found in cache.");
    XCTAssertFalse([self.managerToTest isObjectCached:cacheObjectWithNilKey], @"Object witk nil key cannot be found i cache.");
    XCTAssertFalse([self.managerToTest isObjectCached:cacheObject], @"Object not cached cannot be found in cache.");
}

- (void)testIsObjectCachedWhenCached {
    
    // mock
    VDFCacheObject *cacheObject = [[VDFCacheObject alloc] initWithValue:nil forKey:@"someKey4" withExpirationDate:nil];
    
    // run & assert
    XCTAssertTrue([self.managerToTest isObjectCached:cacheObject], @"Object with key stored in cache should be found.");
}

- (void)testReadCachedObjectWhenNotCached {
    
    // mock
    VDFCacheObject *cacheObject = [[VDFCacheObject alloc] initWithValue:nil forKey:@"someNonExistingKey" withExpirationDate:nil];
    VDFCacheObject *cacheObjectWithNilKey = [[VDFCacheObject alloc] initWithValue:nil forKey:nil withExpirationDate:nil];
    
    // run & assert
    XCTAssertNil([self.managerToTest readCacheObject:nil], @"Nil object cannot be found in cache.");
    XCTAssertNil([self.managerToTest readCacheObject:cacheObjectWithNilKey], @"Object witk nil key cannot be found i cache.");
    XCTAssertNil([self.managerToTest readCacheObject:cacheObject], @"Object not cached cannot be found in cache.");
}

- (void)testReadCachedObjectWhenCached {
    
    // mock
    VDFCacheObject *cacheObject = [[VDFCacheObject alloc] initWithValue:nil forKey:@"someKey4" withExpirationDate:nil];
    
    // run & assert
    XCTAssertEqualObjects([self.managerToTest readCacheObject:cacheObject], ((VDFCacheObject*)[self.managerToTest.cacheObjects objectAtIndex:3]).cacheValue, @"Object with key stored in cache should be found.");
}

- (void)testCacheObjectWhenInvalidData {
    
    // mock
    VDFCacheObject *cacheObjectWithNilKey = [[VDFCacheObject alloc] initWithValue:nil forKey:nil withExpirationDate:nil];
    
    // expect that the internal cache array wont be invoked
    [[self.mockCacheObjectsArray reject] addObject:[OCMArg any]];
    
    // run
    [self.managerToTest cacheObject:nil];
    [self.managerToTest cacheObject:cacheObjectWithNilKey];
    
    // verify
    [self.mockCacheObjectsArray verify];
}

- (void)testCacheObjectWhenNotCachedObject {
    
    // mock
    VDFCacheObject *cacheObject = [[VDFCacheObject alloc] initWithValue:nil forKey:@"someKeyNotCached" withExpirationDate:nil];
    
    // expect that the mock cache object will get new cache object
    [[self.mockCacheObjectsArray expect] addObject:cacheObject];
    
    // run
    [self.managerToTest cacheObject:cacheObject];
    
    // verify
    [self.mockCacheObjectsArray verify];
}

- (void)testCachedObjectWhenCached {
    
    // mock
    VDFCacheObject *cacheObject = [[VDFCacheObject alloc] initWithValue:@"Some value" forKey:@"someKey4" withExpirationDate:[NSDate dateWithTimeIntervalSinceNow:7200]];
    VDFCacheObject *cacheObjectWithoutExpirationDate = [[VDFCacheObject alloc] initWithValue:@"Some value without expiration date" forKey:@"someKey5" withExpirationDate:nil];
    
    // expect that the internal cache array wont be invoked
    [[self.mockCacheObjectsArray reject] addObject:[OCMArg any]];
    
    // run & assert
    [self.managerToTest cacheObject:cacheObject];
    [self.managerToTest cacheObject:cacheObjectWithoutExpirationDate];
    
    // assert
    XCTAssertEqualObjects(cacheObject.cacheValue, ((VDFCacheObject*)[self.managerToTest.cacheObjects objectAtIndex:3]).cacheValue, @"After caching object stored in cache should change value in cache.");
    XCTAssertEqualObjects(cacheObject.expirationDate, ((VDFCacheObject*)[self.managerToTest.cacheObjects objectAtIndex:3]).expirationDate, @"After caching object stored in cache should change expiration date of cache object.");
    XCTAssertEqualObjects(cacheObjectWithoutExpirationDate.cacheValue, ((VDFCacheObject*)[self.managerToTest.cacheObjects objectAtIndex:4]).cacheValue, @"After caching object stored in cache should change value in cache.");
    XCTAssertNil(((VDFCacheObject*)[self.managerToTest.cacheObjects objectAtIndex:4]).expirationDate, @"After caching object withou expiration date stored in cache should change expiration date of cache object to nil.");
    
    // verify
    [self.mockCacheObjectsArray verify];
}

- (void)testFindInInternalCacheIsExpiredItemsRemoved {
    
    // mock
    VDFCacheObject *cacheObject = [self.managerToTest.cacheObjects objectAtIndex:4];
    cacheObject.expirationDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    // expect that the cache object at specified index will be removed from internal cache
    [[self.mockCacheObjectsArray expect] removeObject:cacheObject];
    
    // run
    [self.managerToTest findInInternalCache:@"some non exisitng key"];
    
    // verify
    [self.mockCacheObjectsArray verify];
}

@end

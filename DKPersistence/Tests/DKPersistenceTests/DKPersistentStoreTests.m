@import XCTest;
@import DKPersistence;

#import "DKTestObject1.h"

@interface DKPersistentStore (Test)

@property (nonatomic) NSMutableDictionary<Class, NSMutableArray<NSString *> *> *store;

@end


@interface DKPersistentStoreTests : XCTestCase

@property (nonatomic) DKPersistentStore *store;

@end


@implementation DKPersistentStoreTests

- (void)setUp
{
	self.store = [DKPersistentStore new];
}

- (void)testSingleInsert
{
	[self.store insertObject:[NSNull null] class:[NSNull class]];
	[self.store insertObject:@1 class:[NSNumber class]];
	[self.store insertObject:@"hello" class:[NSString class]];
	[self.store insertObject:@{@"kek":@228} class:[NSDictionary class]];
	[self.store insertObject:@[@1, @2, @3, @"go"] class:[NSArray class]];
	[self.store insertObject:[DKTestObject1 new] class:[DKTestObject1 class]];
	
	NSMutableDictionary<Class, NSMutableArray<NSString *> *> *storage = self.store.store;
	XCTAssertEqual(storage.count, 6);
	XCTAssertEqual(storage[[NSNull class]].count, 1);
	XCTAssertEqual(storage[[NSNumber class]].count, 1);
	XCTAssertEqual(storage[[NSString class]].count, 1);
	XCTAssertEqual(storage[[NSDictionary class]].count, 1);
	XCTAssertEqual(storage[[NSArray class]].count, 1);
	XCTAssertEqual(storage[[DKTestObject1 class]].count, 1);
}

- (void)testMultipleInsert
{
	[self.store insertObject:[DKTestObject1 new] class:[DKTestObject1 class]];
	[self.store insertObject:[DKTestObject1 new] class:[DKTestObject1 class]];
	[self.store insertObject:[NSNull null] class:[NSNull class]];
	
	XCTAssertEqual(self.store.store.count, 2);
	XCTAssertEqual(self.store.store[[DKTestObject1 class]].count, 2);
	XCTAssertEqual(self.store.store[[NSNull class]].count, 1);
}

@end

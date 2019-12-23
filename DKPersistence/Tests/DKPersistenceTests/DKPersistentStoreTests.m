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

- (void)testSingleDelete
{
	DKTestObject1 *object = [DKTestObject1 new];
	[self.store insertObject:object class:[DKTestObject1 class]];
	[self.store deleteObject:object class:[DKTestObject1 class]];
	
	XCTAssertEqual(self.store.store.count, 1);
	XCTAssertNotNil(self.store.store[[DKTestObject1 class]]);
	XCTAssertEqual(self.store.store[[DKTestObject1 class]].count, 0);
}

- (void)testIdenticalDelete
{
	DKTestObject1 *object = [DKTestObject1 new];
	[self.store insertObject:object class:[DKTestObject1 class]];
	[self.store insertObject:object class:[DKTestObject1 class]];
	[self.store deleteObject:object class:[DKTestObject1 class]];
	
	XCTAssertEqual(self.store.store.count, 1);
	XCTAssertNotNil(self.store.store[[DKTestObject1 class]]);
	XCTAssertEqual(self.store.store[[DKTestObject1 class]].count, 1);
}

- (void)testZeroResultsFetch
{
	DKFetchRequest *request = [[DKFetchRequest alloc] initWithEntityClass:[DKTestObject1 class]];
	NSError *error;
	NSArray *results = [self.store executeFetchRequest:request error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(results);
	XCTAssertEqualObjects(results, @[]);
}

- (void)testNoPredicateFetch
{
	[self.store insertObject:@1 class:[NSNumber class]];
	[self.store insertObject:@22.8 class:[NSNumber class]];
	[self.store insertObject:@YES class:[NSNumber class]];
	
	DKFetchRequest *request = [[DKFetchRequest alloc] initWithEntityClass:[NSNumber class]];
	NSError *error;
	NSArray *results = [self.store executeFetchRequest:request error:&error];
	
	XCTAssertNil(error);
	XCTAssertNotNil(results);
	NSArray *expected = @[@1, @22.8, @YES];
	XCTAssertEqualObjects(results, expected);
}

- (void)testPredicateFetch
{
	DKTestObject1 *obj1 = [DKTestObject1 new];
	DKTestObject1 *obj2 = [[DKTestObject1 alloc] initWithNumber:@-1];
	
	[self.store insertObject:obj1 class:[DKTestObject1 class]];
	[self.store insertObject:obj2 class:[DKTestObject1 class]];
	
	DKFetchRequest *request = [[DKFetchRequest alloc] initWithEntityClass:[DKTestObject1 class]];
	request.predicate = [NSPredicate predicateWithValue:NO];
	XCTAssertEqualObjects([self.store executeFetchRequest:request error:nil], @[]);
	
	request.predicate = [NSPredicate predicateWithFormat:@"_numberVar < 0"];
	XCTAssertEqualObjects([self.store executeFetchRequest:request error:nil], @[obj2]);
}

@end

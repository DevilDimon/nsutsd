@import XCTest;
@import DKPersistence;

#import "DKTestObject1.h"

@interface DKCoderTests : XCTestCase
@end


@implementation DKCoderTests

- (void)testNilObject
{
	XCTAssertEqualObjects([DKCoder encodeObject:[NSNull null]], @"null");
	XCTAssertEqualObjects([DKCoder encodeObject:nil], @"null");
}

- (void)testNumber
{
	XCTAssertEqualObjects([DKCoder encodeObject:@1], @"1");
	XCTAssertEqualObjects([DKCoder encodeObject:@2.2], @"2.2");
	XCTAssertEqualObjects([DKCoder encodeObject:@YES], @"1");
}

- (void)testString
{
	XCTAssertEqualObjects([DKCoder encodeObject:@""], @"\"\"");
	XCTAssertEqualObjects([DKCoder encodeObject:@"\""], @"\"\\\"\"");
	XCTAssertEqualObjects([DKCoder encodeObject:@"kek"], @"\"kek\"");
}

- (void)testDictionary
{
	XCTAssertEqualObjects([DKCoder encodeObject:@{}], @"{}");
	XCTAssertEqualObjects([DKCoder encodeObject:@{@"":[NSNull null]}], @"{\"\":null}");
	NSString *encodedDict = [DKCoder encodeObject:@{@"":@21, @"jo\"j":@{@"kek":@1.1}}];
	XCTAssertEqualObjects(encodedDict, @"{\"\":21,\"jo\\\"j\":{\"kek\":1.1}}");
}

- (void)testArray
{
	XCTAssertEqualObjects([DKCoder encodeObject:@[]], @"[]");
	XCTAssertEqualObjects([DKCoder encodeObject:@[@""]], @"[\"\"]");
	NSString *encodedArray = [DKCoder encodeObject:@[@"hello", @1, @2, @3]];
	XCTAssertEqualObjects(encodedArray, @"[\"hello\",1,2,3]");
}

- (void)testCustomObject
{
	DKTestObject1 *testObject = [DKTestObject1 new];
	XCTAssertEqualObjects([DKCoder encodeObject:testObject],
						  @"{\"_numberVar\":14.88,\"_stringVar\":\"cheburek\",\"_dictVar\":{\"jo\":\"ba\"},\"_arrVar\":[2,2,8]}");
}

@end

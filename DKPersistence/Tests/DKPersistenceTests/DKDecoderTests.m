@import XCTest;
@import DKPersistence;

#import "DKTestObject1.h"

@interface DKDecoderTests : XCTestCase
@end


@implementation DKDecoderTests

- (void)testNilObject
{
	XCTAssertNil([DKDecoder decodeObjectOfClass:[NSNumber class] fromString:@"null"]);
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSNull class] fromString:@"null"], [NSNull null]);
}

- (void)testNumber
{
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSNumber class] fromString:@"1"], @1);
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSNumber class] fromString:@"2.2"], @2.2);
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSNumber class] fromString:@"0"], @NO);
}

- (void)testString
{
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSString class] fromString:@"\"\""], @"");
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSString class] fromString:@"\"kek\""], @"kek");
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSString class] fromString:@"\"\\\"\""], @"\"");
}

- (void)testDictionary
{
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSDictionary class] fromString:@"{}"], @{});
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSDictionary class]
											  fromString:@"{\"\":null}"], @{@"":[NSNull null]});
	NSDictionary *expected = @{@"":@21, @"jo\"j":@{@"kek":@1.1}};
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSDictionary class]
											  fromString:@"{\"\":21,\"jo\\\"j\":{\"kek\":1.1}}"], expected);
}

- (void)testArray
{
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSArray class] fromString:@"[]"], @[]);
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSArray class] fromString:@"[\"kek\"]"], @[@"kek"]);
	NSArray *expected = @[@"hello", @1, @2, @3];
	XCTAssertEqualObjects([DKDecoder decodeObjectOfClass:[NSArray class] fromString:@"[\"hello\",1,2,3]"], expected);
}

- (void)testCustomObject
{
	DKTestObject1 *expected = [DKTestObject1 new];
	DKTestObject1 *actual = [DKDecoder decodeObjectOfClass:[DKTestObject1 class]
		fromString:@"{\"_numberVar\":14.88,\"_stringVar\":\"cheburek\",\"_dictVar\":{\"jo\":\"ba\"},\"_arrVar\":[2,2,8]}"];
	XCTAssertEqualObjects(actual, expected);
}

@end

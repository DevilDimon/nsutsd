@import XCTest;
@import DKPersistence;

#import "DKTestObject1.h"

@interface DKCoderTests : XCTestCase

@property (nonatomic) DKCoder *coder;

@end


@implementation DKCoderTests

- (void)setUp
{
	self.coder = [DKCoder new];
}

- (void)testNilObject
{
	XCTAssertEqualObjects([self.coder encodeObject:[NSNull null]], @"nil");
	XCTAssertEqualObjects([self.coder encodeObject:nil], @"nil");
}

- (void)testNumber
{
	XCTAssertEqualObjects([self.coder encodeObject:@1], @"1");
	XCTAssertEqualObjects([self.coder encodeObject:@2.2], @"2.2");
	XCTAssertEqualObjects([self.coder encodeObject:@YES], @"1");
}

- (void)testString
{
	XCTAssertEqualObjects([self.coder encodeObject:@""], @"\"\"");
	XCTAssertEqualObjects([self.coder encodeObject:@"\""], @"\"\\\"\"");
	XCTAssertEqualObjects([self.coder encodeObject:@"kek"], @"\"kek\"");
}

- (void)testDictionary
{
	XCTAssertEqualObjects([self.coder encodeObject:@{}], @"{}");
	XCTAssertEqualObjects([self.coder encodeObject:@{@"":[NSNull null]}], @"{\"\":nil}");
	NSString *encodedDict = [self.coder encodeObject:@{@"":@21, @"jo\"j":@{@"kek":@1.1}}];
	XCTAssertEqualObjects(encodedDict, @"{\"\":21,\"jo\\\"j\":{\"kek\":1.1}}");
}

- (void)testArray
{
	XCTAssertEqualObjects([self.coder encodeObject:@[]], @"[]");
	XCTAssertEqualObjects([self.coder encodeObject:@[@""]], @"[\"\"]");
	NSString *encodedArray = [self.coder encodeObject:@[@"hello", @1, @2, @3]];
	XCTAssertEqualObjects(encodedArray, @"[\"hello\",1,2,3]");
}

- (void)testCustomObject
{
	DKTestObject1 *testObject = [DKTestObject1 new];
	XCTAssertEqualObjects([self.coder encodeObject:testObject],
						  @"{\"_numberVar\":14.88,\"_stringVar\":\"cheburek\",\"_dictVar\":{\"jo\":\"ba\"},\"_arrVar\":[2,2,8]}");
}

@end

@import XCTest;
@import DKPersistence;

@interface DKCoderTests : XCTestCase
@end


@implementation DKCoderTests

- (void)testNilObject
{
	DKCoder *persistence = [DKCoder new];
	XCTAssertEqual([persistence encodeObject:nil], @"nil");
}

@end

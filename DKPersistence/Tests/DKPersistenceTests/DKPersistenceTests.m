@import XCTest;
@import DKPersistence;

@interface DKPersistenceTests : XCTestCase
@end


@implementation DKPersistenceTests

- (void)testNilObject
{
	DKPersistenceService *persistence = [DKPersistenceService new];
	XCTAssertEqual([persistence persistObject:nil], @"nil");
}

@end

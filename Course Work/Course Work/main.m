#import <Foundation/Foundation.h>
@import DKPersistence;


@interface Test1 : NSObject {
	@private
	NSNumber *_numberVar;
	NSString *_stringVar;
	NSDictionary *_dictVar;
	NSArray *_arrVar;
	int a;
}

@end

@implementation Test1

- (instancetype)init
{
	self = [super init];
	if (self == nil) { return nil; }
	
	_numberVar = @14.88;
	_stringVar = @"cheburek";
	_dictVar = @{@"jo":@"joba"};
	_arrVar = @[@2, @2, @8];
	
	return self;
}

@end


// TODO: Tests
int main(int argc, const char * argv[]) {
	@autoreleasepool {
		DKPersistenceService *persistence = [DKPersistenceService new];
		Test1 *test = [Test1 new];
		NSLog(@"%@", [persistence persistObject:@[test, @"\"",@{@"":@21, @"jo\"j":@{@"kek":@1.1}}]]);
	}
	return 0;
}


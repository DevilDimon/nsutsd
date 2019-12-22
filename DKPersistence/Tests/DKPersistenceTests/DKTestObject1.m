#import "DKTestObject1.h"

@implementation DKTestObject1

- (instancetype)init
{
	self = [super init];
	if (self == nil) { return nil; }
	
	_numberVar = @14.88;
	_stringVar = @"cheburek";
	_dictVar = @{@"jo":@"ba"};
	_arrVar = @[@2, @2, @8];
	
	return self;
}

@end

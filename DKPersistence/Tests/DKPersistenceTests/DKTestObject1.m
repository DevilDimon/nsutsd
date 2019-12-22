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

- (BOOL)isEqual:(id)other
{
	if (other == self) {
		return YES;
	} else if (![other isKindOfClass:[self class]]) {
		return NO;
	} else {
		typeof(self) otherObj = other;
		return [_numberVar isEqualToNumber:otherObj->_numberVar] &&
				[_stringVar isEqualToString:otherObj->_stringVar] &&
				[_dictVar isEqualToDictionary:otherObj->_dictVar] &&
				[_arrVar isEqualToArray:otherObj->_arrVar];
	}
}

- (NSUInteger)hash
{
	return _numberVar.hash ^
			_stringVar.hash ^
			_dictVar.hash ^
			_arrVar.hash;
}

@end

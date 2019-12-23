#import "DKFetchRequest.h"

@implementation DKFetchRequest

- (instancetype)initWithEntityClass:(Class)cls
{
	self = [super init];
	if (self == nil) { return; }
	
	_entityClass = cls;
	
	return self;
}



@end

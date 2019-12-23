#import "DKPersistentStore.h"
#import "DKCoder.h"
#import "DKDecoder.h"

@interface DKPersistentStore ()

@property (nonatomic) NSMutableDictionary<Class, NSMutableArray<NSString *> *> *store;

@end


@implementation DKPersistentStore

- (instancetype)init
{
	self = [super init];
	if (self == nil) { return nil; }
	
	_store = [[NSMutableDictionary alloc] init];
	
	return self;
}

- (BOOL)insertObject:(id)object class:(Class)cls
{
	if (![object isKindOfClass:cls]) {
		return NO;
	}
	
	NSString *encoded = [DKCoder encodeObject:object];
	if (encoded == nil) {
		return NO;
	}
	
	NSMutableArray<NSString *> *valuesArray = self.store[cls];
	if (valuesArray == nil) {
		self.store[(id<NSCopying>)cls] = [NSMutableArray arrayWithObject:encoded];
	} else {
		[self.store[cls] addObject:encoded];
	}
	
	return YES;
}

@end

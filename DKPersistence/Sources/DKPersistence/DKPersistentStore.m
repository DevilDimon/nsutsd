#import "DKPersistentStore.h"
#import "DKCoder.h"
#import "DKDecoder.h"
#import "DKFetchRequest.h"

NSErrorDomain _Nonnull DKPersistentStoreErrorDomain = @"DKPersistentStoreErrorDomain";

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

- (void)deleteObject:(id)object class:(Class)cls
{
	if (![object isKindOfClass:cls]) {
		return;
	}
	
	NSString *encoded = [DKCoder encodeObject:object];
	if (encoded == nil) {
		return;
	}
	
	NSMutableArray<NSString *> *valuesArray = self.store[cls];
	NSUInteger indexOfObject = [valuesArray indexOfObject:encoded];
	if (indexOfObject == NSNotFound) {
		return;
	}
	
	[valuesArray removeObjectAtIndex:indexOfObject];
}

- (NSArray *)executeFetchRequest:(DKFetchRequest *)request error:(NSError *__autoreleasing *)error
{
	if (request.entityClass == nil) {
		*error = [NSError errorWithDomain:DKPersistentStoreErrorDomain code:1 userInfo:nil];
		return nil;
	}
	
	NSMutableArray *result = [NSMutableArray array];
	
	for (NSString *encoded in self.store[request.entityClass]) {
		id decoded = [DKDecoder decodeObjectOfClass:request.entityClass fromString:encoded];
		if (decoded == nil) {
			continue;
		}
		
		if (request.predicate == nil || [request.predicate evaluateWithObject:decoded]) {
			[result addObject:decoded];
		}
	}
	
	return [result copy];
}

@end

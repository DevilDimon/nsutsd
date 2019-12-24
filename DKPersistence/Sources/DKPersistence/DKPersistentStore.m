#import "DKPersistentStore.h"
#import "DKCoder.h"
#import "DKDecoder.h"
#import "DKFetchRequest.h"

@import ObjectiveC;

NSErrorDomain _Nonnull DKPersistentStoreErrorDomain = @"DKPersistentStoreErrorDomain";

@interface DKPersistentStore ()

@property (nonatomic) NSMutableDictionary<Class, NSMutableArray<NSString *> *> *store;
@property (nonatomic) NSUInteger pseudoClassCount;

@end


@implementation DKPersistentStore

- (instancetype)init
{
	self = [super init];
	if (self == nil) { return nil; }
	
	_store = [[NSMutableDictionary alloc] init];
	_pseudoClassCount = 0;
	
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
	
	if (request.ivarsToFetch.count == 0) {
		return [result copy];
	}
	
	const char *pseudoClassName = [NSString stringWithFormat:@"DKPseudoClass%lu", self.pseudoClassCount].UTF8String;
	self.pseudoClassCount++;
	Class pseudoClass = objc_allocateClassPair([NSObject class], pseudoClassName, 0);
	for (NSString *ivarName in request.ivarsToFetch) {
		const char *ivarEncoding = ivar_getTypeEncoding(class_getInstanceVariable(request.entityClass, ivarName.UTF8String));
		NSUInteger size, alignment;
		NSGetSizeAndAlignment(ivarEncoding, &size, &alignment);
		class_addIvar(pseudoClass, ivarName.UTF8String, size, alignment, ivarEncoding);
	}
	objc_registerClassPair(pseudoClass);
	
	NSMutableArray *projectedResult = [NSMutableArray array];
	for (id object in result) {
		id pseudoInstance = [[pseudoClass alloc] init];
		
		for (NSString *ivarName in request.ivarsToFetch) {
			id value = [object valueForKey:ivarName];
			[pseudoInstance setValue:value forKey:ivarName];
		}
		
		[projectedResult addObject:pseudoInstance];
	}
	
	return [projectedResult copy];
}

@end

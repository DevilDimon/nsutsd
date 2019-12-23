@import Foundation;

@class DKFetchRequest;

extern NSErrorDomain _Nonnull DKPersistentStoreErrorDomain;

NS_ASSUME_NONNULL_BEGIN

@interface DKPersistentStore: NSObject

- (BOOL)insertObject:(id)object class:(Class)cls;
- (void)deleteObject:(id)object class:(Class)cls;
- (NSArray *)executeFetchRequest:(DKFetchRequest *)request error:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END

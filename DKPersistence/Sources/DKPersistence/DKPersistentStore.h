@import Foundation;
@import ObjectiveC;

NS_ASSUME_NONNULL_BEGIN

@interface DKPersistentStore: NSObject

- (BOOL)insertObject:(id)object class:(Class)cls;
- (void)deleteObject:(id)object class:(Class)cls;

@end

NS_ASSUME_NONNULL_END

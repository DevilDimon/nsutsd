@import Foundation;

@interface DKFetchRequest : NSObject

@property (nonatomic, readonly) Class entityClass;
@property (nonatomic) NSPredicate *predicate;
@property (nonatomic, copy) NSArray<NSString *> *ivarsToFetch;

- (instancetype)initWithEntityClass:(Class)cls;

@end

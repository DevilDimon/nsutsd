@import Foundation;

@interface DKFetchRequest : NSObject

@property (nonatomic, readonly) Class entityClass;
@property (nonatomic) NSPredicate *predicate;

- (instancetype)initWithEntityClass:(Class)cls;

@end

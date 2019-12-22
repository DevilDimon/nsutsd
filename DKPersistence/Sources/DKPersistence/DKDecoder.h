#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKDecoder : NSObject

+ (nullable id)decodeObjectOfClass:(Class)cls fromString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END



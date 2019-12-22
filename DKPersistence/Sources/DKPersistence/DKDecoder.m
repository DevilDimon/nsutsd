#import "DKDecoder.h"

#import <objc/runtime.h>

@implementation DKDecoder

+ (id)decodeObjectOfClass:(Class)cls fromString:(nonnull NSString *)string
{
	if ([string isEqualToString:@"null"]) {
		return cls == [NSNull class] ? [NSNull null] : nil;
	}
	
	if (cls == [NSNumber class]) {
		return [[self class] decodeNumberFromString:string];
	}
	
	if (cls == [NSString class]) {
		return [[self class] decodeStringFromString:string];
	}
	
	if (cls == [NSDictionary class]) {
		return [[self class] decodeDictionaryFromString:string];
	}
	
	if (cls == [NSArray class]) {
		return [[self class] decodeArrayFromString:string];
	}
	
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
														 options:0 error:nil];
	if (![dict isKindOfClass:[NSDictionary class]]) {
		return nil;
	}
	
	id result = [[cls alloc] init];
	unsigned ivarCount = 0;
	Ivar *ivars = class_copyIvarList(cls, &ivarCount);
	for (int i = 0; i < ivarCount; i++) {
		Ivar ivar = ivars[i];
		NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
		id value = dict[key];
		object_setIvar(result, ivar, value);
	}
	
	return result;
}

+ (NSNumber *)decodeNumberFromString:(NSString *)string
{
	static NSNumberFormatter *formatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [[NSNumberFormatter alloc] init];
		formatter.numberStyle = NSNumberFormatterDecimalStyle;
		formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
	});
	
	return [formatter numberFromString:string];
}

+ (NSString *)decodeStringFromString:(NSString *)string
{
	return [[[string stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(0, 1)]
			 stringByReplacingOccurrencesOfString:@"\"" withString:@"" options:0 range:NSMakeRange(string.length - 2, 1)]
			stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
}

+ (NSDictionary *)decodeDictionaryFromString:(NSString *)string
{
	id result = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
												options:0 error:nil];
	return [result isKindOfClass:[NSDictionary class]] ? result : nil;
}

+ (NSArray *)decodeArrayFromString:(NSString *)string
{
	id result = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
												options:0 error:nil];
	return [result isKindOfClass:[NSArray class]] ? result : nil;
}

@end

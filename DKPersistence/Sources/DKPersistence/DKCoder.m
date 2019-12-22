#import "DKCoder.h"

#import <objc/runtime.h>

@implementation DKCoder

+ (NSString *)encodeObject:(id)object
{
	if (object == nil || [object isKindOfClass:[NSNull class]]) { return @"null"; }
	
	if ([object isKindOfClass:[NSNumber class]]) {
		return ((NSNumber *)object).stringValue;
	}
	
	if ([object isKindOfClass:[NSString class]]) {
		NSString *string = object;
		return [[self class] encodeString:string];
	}
	
	if ([object isKindOfClass:[NSDictionary class]]) {
		NSDictionary *dictionary = object;
		return [[self class] encodeDictionary:dictionary];
	}
	
	if ([object isKindOfClass:[NSArray class]]) {
		NSArray *array = object;
		return [[self class] encodeArray:array];
	}
	
	NSMutableString *result = [NSMutableString stringWithString:@"{"];
	unsigned ivarCount = 0;
	BOOL hasIvars = NO;
	Ivar *ivarList = class_copyIvarList([object class], &ivarCount);
	for (int i = 0; i < ivarCount; i++) {
		NSString *name = [NSString stringWithUTF8String:ivar_getName(ivarList[i])];
		id ivar = object_getIvar(object, ivarList[i]);
		if (ivar == nil) {
			continue;
		}
		
		NSString *persisted = [[self class] encodeObject:ivar];
		if (persisted == nil) {
			continue;
		}
		
		hasIvars = YES;
		[result appendFormat:@"%@:%@,", [[self class] encodeObject:name], persisted];
	}
	
	if (hasIvars) {
		NSRange range = NSMakeRange(result.length - 1, 1);
		[result deleteCharactersInRange:range];
	}
	[result appendString:@"}"];
	return [result copy];
}

+ (NSString *)encodeString:(NSString *)string
{
	NSMutableString *result = [NSMutableString stringWithString:@"\""];
	NSString *encodedString = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	[result appendFormat:@"%@\"", encodedString];
	return [result copy];
}

+ (NSString *)encodeDictionary:(NSDictionary *)dictionary
{
	NSMutableString *result = [NSMutableString stringWithString:@"{"];
	BOOL hasElements = NO;
	for (NSString *key in dictionary) {
		NSString *persisted = [[self class] encodeObject:dictionary[key]];
		if (persisted == nil) {
			continue;
		}
		hasElements = YES;
		[result appendFormat:@"%@:%@,",
			[[self class] encodeObject:key], persisted];
	}
	
	if (hasElements) {
		NSRange range = NSMakeRange(result.length - 1, 1);
		[result deleteCharactersInRange:range];
	}
	[result appendString:@"}"];
	return [result copy];
}

+ (NSString *)encodeArray:(NSArray *)array
{
	NSMutableString *result = [NSMutableString stringWithString:@"["];
	BOOL hasElements = NO;
	for (id item in array) {
		NSString *persisted = [[self class] encodeObject:item];
		if (persisted == nil) {
			continue;
		}
		hasElements = YES;
		[result appendFormat:@"%@,", persisted];
	}
	
	if (hasElements) {
		NSRange range = NSMakeRange(result.length - 1, 1);
		[result deleteCharactersInRange:range];
	}
	[result appendString:@"]"];
	return [result copy];
}

@end


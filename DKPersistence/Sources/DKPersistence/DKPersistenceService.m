#import "DKPersistenceService.h"

#import <objc/runtime.h>

@implementation DKPersistenceService

- (NSString *)persistObject:(id)object
{
	if (object == nil) { return @"nil"; }
	
	if ([object isKindOfClass:[NSNumber class]]) {
		return ((NSNumber *)object).stringValue;
	}
	
	if ([object isKindOfClass:[NSString class]]) {
		NSString *string = object;
		NSMutableString *result = [NSMutableString stringWithString:@"\""];
		NSString *encodedString = [string stringByReplacingOccurrencesOfString:@"\""
			withString:@"\\\"" options:NSLiteralSearch
			range:NSMakeRange(0, string.length)];
		[result appendFormat:@"%@\"", encodedString];
		return [result copy];
	}
	
	if ([object isKindOfClass:[NSDictionary class]]) {
		NSMutableString *result = [NSMutableString stringWithString:@"{"];
		BOOL hasElements = NO;
		NSDictionary *dictionary = object;
		for (NSString *key in dictionary) {
			NSString *persisted = [self persistObject:dictionary[key]];
			if (persisted == nil) {
				continue;
			}
			hasElements = YES;
			[result appendFormat:@"%@:%@,",
				[self persistObject:key], persisted];
		}
		
		if (hasElements) {
			NSRange range = NSMakeRange(result.length - 1, 1);
			[result deleteCharactersInRange:range];
		}
		[result appendString:@"}"];
		return [result copy];
	}
	
	if ([object isKindOfClass:[NSArray class]]) {
		NSMutableString *result = [NSMutableString stringWithString:@"["];
		BOOL hasElements = NO;
		NSArray *array = object;
		for (id item in array) {
			NSString *persisted = [self persistObject:item];
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
		
		NSString *persisted = [self persistObject:ivar];
		if (persisted == nil) {
			continue;
		}
		
		hasIvars = YES;
		[result appendFormat:@"%@:%@,", [self persistObject:name], persisted];
	}
	
	if (hasIvars) {
		NSRange range = NSMakeRange(result.length - 1, 1);
		[result deleteCharactersInRange:range];
	}
	[result appendString:@"}"];
	return [result copy];
}

@end


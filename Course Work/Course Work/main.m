#import <Foundation/Foundation.h>
@import DKPersistence;


int main(int argc, const char * argv[]) {
	@autoreleasepool {
		NSLog(@"%@", [persistence encodeObject:@[test, @"\"",@{@"":@21, @"jo\"j":@{@"kek":@1.1}}]]);
	}
	return 0;
}


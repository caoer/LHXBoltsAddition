//
//  NSDictionary+TMAddition.m
//  TMAddition
//

#import "NSDictionary+LHXAddition.h"

@implementation NSDictionary (LHXAddition)

- (void)lhx_each:(void (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		block(key, obj);
	}];
}

- (void)lhx_apply:(void (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	[self enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
		block(key, obj);
	}];
}

- (id)lhx_match:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	return self[[[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
		if (block(key, obj)) {
			*stop = YES;
			return YES;
		}

		return NO;
	}] anyObject]];
}

- (NSDictionary *)lhx_select:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSArray *keys = [[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
		return block(key, obj);
	}] allObjects];

	NSArray *objects = [self objectsForKeys:keys notFoundMarker:[NSNull null]];
	return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

- (NSDictionary *)lhx_reject:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);
	return [self lhx_select:^BOOL(id key, id obj) {
		return !block(key, obj);
	}];
}

- (NSDictionary *)lhx_map:(id (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];

	[self lhx_each:^(id key, id obj) {
		id value = block(key, obj) ?: [NSNull null];
		result[key] = value;
	}];

	return result;
}

- (BOOL)lhx_any:(BOOL (^)(id key, id obj))block
{
	return [self lhx_match:block] != nil;
}

- (BOOL)lhx_none:(BOOL (^)(id key, id obj))block
{
	return [self lhx_match:block] == nil;
}

- (BOOL)lhx_all:(BOOL (^)(id key, id obj))block
{
	NSParameterAssert(block != nil);

	__block BOOL result = YES;

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if (!block(key, obj)) {
			result = NO;
			*stop = YES;
		}
	}];

	return result;
}

@end

//
//  NSArray+TMAddition.m
//  TMAddition
//

#import "NSArray+LHXAddition.h"

@implementation NSArray (LHXAddition)

- (void)lhx_each:(void (^)(id obj))block {
    NSParameterAssert(block != nil);

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)lhx_apply:(void (^)(id obj))block {
    NSParameterAssert(block != nil);

    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (id)lhx_match:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);

    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];

    if (index == NSNotFound)
        return nil;

    return self[index];
}

- (NSArray *)lhx_select:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
}

- (NSArray *)lhx_reject:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    return [self lhx_select:^BOOL(id obj) {
        return !block(obj);
    }];
}

- (NSArray *)lhx_map:(id (^)(id obj))block {
    NSParameterAssert(block != nil);

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj) ?: [NSNull null];
        [result addObject:value];
    }];

    return result;
}

- (NSArray *)lhx_compact:(id (^)(id obj))block {
    NSParameterAssert(block != nil);

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        if (value) {
            [result addObject:value];
        }
    }];

    return result;
}

- (id)lhx_reduce:(id)initial withBlock:(__nullable id (^)(__nullable id sum, id obj))block {
    NSParameterAssert(block != nil);

    __block id result = initial;

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];

    return result;
}

- (NSInteger)lhx_reduceInteger:(NSInteger)initial withBlock:(NSInteger(^)(NSInteger result, id obj))block {
    NSParameterAssert(block != nil);

    __block NSInteger result = initial;

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];

    return result;
}

- (CGFloat)lhx_reduceFloat:(CGFloat)inital withBlock:(CGFloat(^)(CGFloat result, id obj))block {
    NSParameterAssert(block != nil);

    __block CGFloat result = inital;

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];

    return result;
}

- (BOOL)lhx_any:(BOOL (^)(id obj))block {
    return [self lhx_match:block] != nil;
}

- (BOOL)lhx_none:(BOOL (^)(id obj))block {
    return [self lhx_match:block] == nil;
}

- (BOOL)lhx_all:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);

    __block BOOL result = YES;

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!block(obj)) {
            result = NO;
            *stop = YES;
        }
    }];

    return result;
}

- (BOOL)lhx_corresponds:(NSArray *)list withBlock:(BOOL (^)(id obj1, id obj2))block {
    NSParameterAssert(block != nil);

    __block BOOL result = NO;

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx < list.count) {
            id obj2 = list[idx];
            result = block(obj, obj2);
        }
        else {
            result = NO;
        }
        *stop = !result;
    }];

    return result;
}

@end

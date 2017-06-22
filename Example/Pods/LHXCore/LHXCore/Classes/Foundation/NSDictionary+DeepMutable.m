

#import "NSDictionary+DeepMutable.h"
#import "NSArray+DeepMutable.h"

@implementation NSDictionary (DeepMutable)

- (NSMutableDictionary *)lhx_mutableDeepCopy {
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    NSArray *keys = self.allKeys;

    for (id key in keys) {
        id oneValue = [self objectForKey:key];
        id oneCopy = nil;

        if ([oneValue respondsToSelector:@selector(lhx_mutableDeepCopy)]) {
            oneCopy = [oneValue lhx_mutableDeepCopy];
        }
        else if ([oneValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            oneCopy = [oneValue mutableCopy];
        }
        else if ([oneValue conformsToProtocol:@protocol(NSCopying)]) {
            oneCopy = [oneValue copy];
        }
        else {
            oneCopy = oneValue;
        }

        [returnDictionary setValue:oneCopy forKey:key];
    }
    return returnDictionary;
}

- (NSMutableDictionary *)lhx_immutableDeepCopy {
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    NSArray *keys = self.allKeys;

    for (id key in keys) {
        id oneValue = [self objectForKey:key];
        id oneCopy = nil;

        if ([oneValue respondsToSelector:@selector(lhx_immutableDeepCopy)]) {
            oneCopy = [oneValue lhx_immutableDeepCopy];
        }
        else if ([oneValue conformsToProtocol:@protocol(NSCopying)]) {
            oneCopy = [oneValue copy];
        }
        else {
            oneCopy = oneValue;
        }

        [returnDictionary setValue:oneCopy forKey:key];
    }
    return [returnDictionary copy];
}
@end

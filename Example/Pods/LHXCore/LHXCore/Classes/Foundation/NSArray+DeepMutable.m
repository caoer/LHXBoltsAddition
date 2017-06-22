
#import "NSArray+DeepMutable.h"
#import "NSDictionary+DeepMutable.h"

@implementation NSArray (DeepMutable)

- (NSMutableArray *)lhx_mutableDeepCopy {
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:self.count];

    for (id oneValue in self) {
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

        [returnArray addObject:oneCopy];
    }

    return returnArray;
}

- (NSArray *)lhx_immutableDeepCopy {
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:self.count];

    for (id oneValue in self) {
        id oneCopy = nil;

        if ([oneValue respondsToSelector:@selector(lhx_mutableDeepCopy)]) {
            oneCopy = [oneValue lhx_immutableDeepCopy];
        }
        else if ([oneValue conformsToProtocol:@protocol(NSCopying)]) {
            oneCopy = [oneValue copy];
        }
        else {
            oneCopy = oneValue;
        }

        [returnArray addObject:oneCopy];
    }

    return [returnArray copy];
}
@end

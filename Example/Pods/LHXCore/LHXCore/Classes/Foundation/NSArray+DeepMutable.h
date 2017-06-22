
#import <Foundation/Foundation.h>

@interface NSArray (DeepMutable)

- (NSMutableArray *)lhx_mutableDeepCopy;

@end

@interface NSArray (DeepImmutable)

- (NSArray *)lhx_immutableDeepCopy;
@end

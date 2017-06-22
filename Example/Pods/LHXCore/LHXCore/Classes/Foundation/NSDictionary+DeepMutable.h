

#import <Foundation/Foundation.h>

@interface NSDictionary (DeepMutable)

- (NSMutableDictionary *)lhx_mutableDeepCopy;

@end


@interface NSDictionary (DeepImmutable)

- (NSDictionary *)lhx_immutableDeepCopy;
@end

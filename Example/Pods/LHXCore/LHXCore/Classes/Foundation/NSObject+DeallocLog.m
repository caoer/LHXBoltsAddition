//
//  NSObject+DeallocLog.m
//  DragonMenuDemo
//
//  Created by Qitao Yang on 08/06/2017.
//  Copyright © 2017 LightHouseX. All rights reserved.
//

#import "NSObject+DeallocLog.h"
#import <objc/runtime.h>

static inline void LHX_Swizzle(_Nonnull Class c,_Nonnull SEL orig,_Nonnull SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@implementation NSObject (DeallocLog)

- (void)setLhx_shouldLogWhenDealloc:(BOOL)lhx_shouldLogWhenDealloc {
    objc_setAssociatedObject(self, @selector(lhx_shouldLogWhenDealloc), @(lhx_shouldLogWhenDealloc),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)lhx_shouldLogWhenDealloc {
    return [objc_getAssociatedObject(self, @selector(lhx_shouldLogWhenDealloc)) boolValue];
}

#ifdef DEBUG
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LHX_Swizzle(self, NSSelectorFromString(@"dealloc"), @selector(_myDealloc));
    });
}
#endif

- (NSString *_Nonnull)lhx_memoryAddress; {
    return [NSString stringWithFormat:@"%p", self];
}

- (void)_myDealloc {
    if (self.lhx_shouldLogWhenDealloc) {
#ifdef DEBUG
            NSLog(@"----- 💀 [%@] Dealloc!",NSStringFromClass([self class]));
#endif
    }
    [self _myDealloc];
}

@end

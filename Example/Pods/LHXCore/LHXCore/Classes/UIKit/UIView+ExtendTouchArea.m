//
//  UIView+ExtendTouchArea.m
//  DragonMenuDemo
//
//  Created by Qitao Yang on 07/06/2017.
//  Copyright © 2017 LightHouseX. All rights reserved.
//

#import "UIView+ExtendTouchArea.h"
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

@implementation UIView (ExtendTouchArea)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LHX_Swizzle(self, @selector(pointInside:withEvent:), @selector(lhx_PointInside:withEvent:));
    });
}

- (BOOL)lhx_PointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets d = self.lhx_touchExtendInset;
    if (UIEdgeInsetsEqualToEdgeInsets(d, UIEdgeInsetsZero) || self.hidden ||
        ([self isKindOfClass:UIControl.class] && !((UIControl *)self).enabled)) {
        return [self lhx_PointInside:point withEvent:event]; // original implementation
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.lhx_touchExtendInset);
    hitFrame.size.width = MAX(hitFrame.size.width, 0); // don't allow negative sizes
    hitFrame.size.height = MAX(hitFrame.size.height, 0);
    return CGRectContainsPoint(hitFrame, point);
}

- (void)setLhx_touchExtendInset:(UIEdgeInsets)lhx_touchExtendInset {
    objc_setAssociatedObject(self, @selector(lhx_touchExtendInset), [NSValue valueWithUIEdgeInsets:lhx_touchExtendInset],
                             OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)lhx_touchExtendInset {
    return [objc_getAssociatedObject(self, @selector(lhx_touchExtendInset)) UIEdgeInsetsValue];
}


@end

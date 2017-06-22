//
//  LHXKeyboardManager.m
//  DragonMenuDemo
//
//  Created by Qitao Yang on 08/06/2017.
//  Copyright © 2017 LightHouseX. All rights reserved.
//

#import "LHXKeyboardManager.h"

@implementation LHXKeyboardManager  {
    NSHashTable *_observers;
}

+ (instancetype)defaultManager {
    static LHXKeyboardManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] _init];
    });
    return mgr;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"MMKeyboardManager init error" reason:@"Use 'defaultManager' to get instance." userInfo:nil];
    return [super init];
}

- (instancetype)_init {
    self = [super init];
    _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:0];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardFrameWillChangeNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    return self;
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self defaultManager];
    });
}

- (void)addObserver:(id<LHXKeyboardObserver>)observer {
    if (!observer) return;
    [_observers addObject:observer];
}

- (void)removeObserver:(id<LHXKeyboardObserver>)observer {
    if (!observer) return;
    [_observers removeObject:observer];
}

- (void)_keyboardFrameWillChangeNotification:(NSNotification *)notif {
    if (![notif.name isEqualToString:UIKeyboardWillChangeFrameNotification]) return;
    NSDictionary *info = notif.userInfo;
    if (!info) return;
    
    NSValue *beforeValue = info[UIKeyboardFrameBeginUserInfoKey];
    NSValue *afterValue = info[UIKeyboardFrameEndUserInfoKey];
    NSNumber *curveNumber = info[UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *durationNumber = info[UIKeyboardAnimationDurationUserInfoKey];
    
    CGRect before = beforeValue.CGRectValue;
    CGRect after = afterValue.CGRectValue;
    UIViewAnimationCurve curve = curveNumber.integerValue;
    NSTimeInterval duration = durationNumber.doubleValue;
    
    // ignore zero end frame
    if (after.size.width <= 0 && after.size.height <= 0) return;
    
    LHXKeyboardContext context = {0};
    context.willShow = before.origin.y > after.origin.y;
    context.fromFrame = before;
    context.toFrame = after;
    context.animationDuration = duration;
    context.animationCurve = curve;
    context.animationOption = curve << 16;
    
    for (id<LHXKeyboardObserver> observer in _observers.copy) {
        if ([observer respondsToSelector:@selector(keyboardChangedWithContext:)]) {
            [observer keyboardChangedWithContext:context];
        }
    }
}

@end

//
//  LHXKeyboardManager.h
//  DragonMenuDemo
//
//  Created by Qitao Yang on 08/06/2017.
//  Copyright © 2017 LightHouseX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct {
    BOOL willShow;   ///< Keyboard visible after transition.
    CGRect fromFrame; ///< Keyboard frame before transition.
    CGRect toFrame;   ///< Keyboard frame after transition.
    NSTimeInterval animationDuration;       ///< Keyboard transition animation duration.
    UIViewAnimationCurve animationCurve;    ///< Keyboard transition animation curve.
    UIViewAnimationOptions animationOption; ///< Keybaord transition animation option.
} LHXKeyboardContext;


@protocol LHXKeyboardObserver <NSObject>
@optional
- (void)keyboardChangedWithContext:(LHXKeyboardContext)context;

- (void)keyboardWillShowWithContext:(LHXKeyboardContext)context;

- (void)keyboardWillHideWithContext:(LHXKeyboardContext)context;
@end

NS_ASSUME_NONNULL_BEGIN

@interface LHXKeyboardManager : NSObject

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

+ (nullable instancetype)defaultManager;

/**
 Add an observer to manager to get keyboard change information.
 This method makes a weak reference to the observer.
 
 @param observer An observer.
 This method will do nothing if the observer is nil, or already added.
 */
- (void)addObserver:(id<LHXKeyboardObserver>)observer;

/**
 Remove an observer from manager.
 
 @param observer An observer.
 This method will do nothing if the observer is nil, or not in manager.
 */
- (void)removeObserver:(id<LHXKeyboardObserver>)observer;

@end

NS_ASSUME_NONNULL_END

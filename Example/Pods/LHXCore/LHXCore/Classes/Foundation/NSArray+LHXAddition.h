//
//  NSArray+TMKit.h
//  TMKit
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h> // for CGFloat
#import "LHXMacros.h"

NS_ASSUME_NONNULL_BEGIN

/** Block extensions for NSArray.


 @see NSDictionary(TMKit)
 @see NSSet(TMKit)
 */
@interface __GENERICS(NSArray, ObjectType) (LHXAddition)

/** Loops through an array and executes the given block with each object.

 @param block A single-argument, void-returning code block.
 */
- (void)lhx_each:(void (^)(ObjectType obj))block;

/** Enumerates through an array concurrently and executes
 the given block once for each object.

 Enumeration will occur on appropriate background queues. This
 will have a noticeable speed increase, especially on dual-core
 devices, but you *must* be aware of the thread safety of the
 objects you message from within the block. Be aware that the
 order of objects is not necessarily the order each block will
 be called in.

 @param block A single-argument, void-returning code block.
 */
- (void)lhx_apply:(void (^)(ObjectType obj))block;

/** Loops through an array to find the object matching the block.

 tm_match: is functionally identical to tm_select:, but will stop and return
 on the first match.

 @param block A single-argument, `BOOL`-returning code block.
 @return Returns the object, if found, or `nil`.
 @see tm_select:
 */
- (nullable id)lhx_match:(BOOL (^)(ObjectType obj))block;

/** Loops through an array to find the objects matching the block.

 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of the objects found.
 @see tm_match:
 */
- (NSArray *)lhx_select:(BOOL (^)(ObjectType obj))block;

/** Loops through an array to find the objects not matching the block.

 This selector performs *literally* the exact same function as tm_select: but in reverse.

 This is useful, as one may expect, for removing objects from an array.
	 NSArray *new = [computers tm_reject:^BOOL(id obj) {
	   return ([obj isUgly]);
	 }];

 @param block A single-argument, BOOL-returning code block.
 @return Returns an array of all objects not found.
 */
- (NSArray *)lhx_reject:(BOOL (^)(ObjectType obj))block;

/** Call the block once for each object and create an array of the return values.

 This is sometimes referred to as a transform, mutating one of each object:
	 NSArray *new = [stringArray tm_map:^id(id obj) {
	   return [obj stringByAppendingString:@".png"]);
	 }];

 @param block A single-argument, object-returning code block.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)lhx_map:(id (^)(ObjectType obj))block;

/** Behaves like map, but doesn't add NSNull objects if you return nil in the block.

 @param block A single-argument, object-returning code block.
 @return Returns an array of the objects returned by the block.
 */
- (NSArray *)lhx_compact:(id (^)(ObjectType obj))block;

/** Arbitrarily accumulate objects using a block.

 The concept of this selector is difficult to illustrate in words. The sum can
 be any NSObject, including (but not limited to) a string, number, or value.

 For example, you can concentate the strings in an array:
	 NSString *concentrated = [stringArray tm_reduce:@"" withBlock:^id(id sum, id obj) {
	   return [sum stringByAppendingString:obj];
	 }];

 You can also do something like summing the lengths of strings in an array:
	 NSUInteger value = [[[stringArray tm_reduce:nil withBlock:^id(id sum, id obj) {
	   return @([sum integerValue] + obj.length);
	 }]] unsignedIntegerValue];

 @param initial The value of the reduction at its start.
 @param block A block that takes the current sum and the next object to return the new sum.
 @return An accumulated value.
 */
- (nullable id)lhx_reduce:(id)initial withBlock:(__nullable id (^)(__nullable id sum, ObjectType obj))block;

/**
 Sometimes we just want to loop an objects list and reduce one property, where
 each result is a primitive type.

 For example, say we want to calculate the total age of a list of people.

 Code without using block will be something like:

	 NSArray *peoples = @[p1, p2, p3];
	 NSInteger totalAge = 0;
	 for (People *people in peoples) {
	     totalAge += [people age];
	 }

 We can use a block to make it simpler:

	 NSArray *peoples = @[p1, p2, p3];
	 NSInteger totalAge = [peoples reduceInteger:0 withBlock:^(NSInteger result, id obj, NSInteger index) {
	 	 return result + [obj age];
	 }];

 */
- (NSInteger)lhx_reduceInteger:(NSInteger)initial withBlock:(NSInteger(^)(NSInteger result, ObjectType obj))block;

/**
 Sometimes we just want to loop an objects list and reduce one property, where
 each result is a primitive type.
 
 For instance, say we want to caculate the total balance from a list of people.
 
 Code without using a block will be something like:
 
	 NSArray *peoples = @[p1, p2, p3];
	 CGFloat totalBalance = 0;
	 for (People *people in peoples) {
	     totalBalance += [people balance];
	 }
 
 We can use a block to make it simpler:
 
	 NSArray *peoples = @[p1, p2, p3];
	 CGFloat totalBalance = [peoples reduceFloat:.0f WithBlock:^CGFloat(CGFloat result, id obj, NSInteger index) {
	 	 return result + [obj balance];
	 }];

 */

- (CGFloat)lhx_reduceFloat:(CGFloat)inital withBlock:(CGFloat(^)(CGFloat result, ObjectType obj))block;

/** Loops through an array to find whether any object matches the block.

 This method is similar to the Scala list `exists`. It is functionally
 identical to tm_match: but returns a `BOOL` instead. It is not recommended
 to use tm_any: as a check condition before executing tm_match:, since it would
 require two loops through the array.

 For example, you can find if a string in an array starts with a certain letter:

	 NSString *letter = @"A";
	 BOOL containsLetter = [stringArray tm_any:^(id obj) {
	   return [obj hasPrefix:@"A"];
	 }];

 @param block A single-argument, BOOL-returning code block.
 @return YES for the first time the block returns YES for an object, NO otherwise.
 */
- (BOOL)lhx_any:(BOOL (^)(ObjectType obj))block;

/** Loops through an array to find whether no objects match the block.

 This selector performs *literally* the exact same function as tm_all: but in reverse.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns NO for all objects in the array, NO otherwise.
 */
- (BOOL)lhx_none:(BOOL (^)(ObjectType obj))block;

/** Loops through an array to find whether all objects match the block.

 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the array, NO otherwise.
 */
- (BOOL)lhx_all:(BOOL (^)(ObjectType obj))block;

/** Tests whether every element of this array relates to the corresponding element of another array according to match by block.

 For example, finding if a list of numbers corresponds to their sequenced string values;
 NSArray *numbers = @[ @(1), @(2), @(3) ];
 NSArray *letters = @[ @"1", @"2", @"3" ];
 BOOL doesCorrespond = [numbers tm_corresponds:letters withBlock:^(id number, id letter) {
	return [[number stringValue] isEqualToString:letter];
 }];

 @param list An array of objects to compare with.
 @param block A two-argument, BOOL-returning code block.
 @return Returns a BOOL, true if every element of array relates to corresponding element in another array.
 */
- (BOOL)lhx_corresponds:(NSArray *)list withBlock:(BOOL (^)(ObjectType obj1, id obj2))block;

@end

NS_ASSUME_NONNULL_END

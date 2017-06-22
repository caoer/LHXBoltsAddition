//
//  LHXThreadSafeMapTable.h
//  Pods
//
//  Created by Zitao Xiong on 12/23/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHXThreadSafeMapTable<KeyType, ObjectType> : NSObject <NSCopying, NSCoding, NSFastEnumeration>

- (instancetype)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity;
- (instancetype)initWithKeyPointerFunctions:(NSPointerFunctions *)keyFunctions valuePointerFunctions:(NSPointerFunctions *)valueFunctions capacity:(NSUInteger)initialCapacity;

+ (NSMapTable<KeyType, ObjectType> *)mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions;

+ (NSMapTable<KeyType, ObjectType> *)strongToStrongObjectsMapTable NS_AVAILABLE(10_8, 6_0);
+ (NSMapTable<KeyType, ObjectType> *)weakToStrongObjectsMapTable NS_AVAILABLE(10_8, 6_0); // entries are not necessarily purged right away when the weak key is reclaimed
+ (NSMapTable<KeyType, ObjectType> *)strongToWeakObjectsMapTable NS_AVAILABLE(10_8, 6_0);
+ (NSMapTable<KeyType, ObjectType> *)weakToWeakObjectsMapTable NS_AVAILABLE(10_8, 6_0); // entries are not necessarily purged right away when the weak key or object is reclaimed

///* return an NSPointerFunctions object reflecting the functions in use.  This is a new autoreleased object that can be subsequently modified and/or used directly in the creation of other pointer "collections". */
//@property (readonly, copy) NSPointerFunctions *keyPointerFunctions;
//@property (readonly, copy) NSPointerFunctions *valuePointerFunctions;

- (nullable ObjectType)objectForKey:(nullable KeyType)aKey;

- (void)removeObjectForKey:(nullable KeyType)aKey;
- (void)setObject:(nullable ObjectType)anObject forKey:(nullable KeyType)aKey;   // add/replace value (CFDictionarySetValue, NSMapInsert)

@property (readonly) NSUInteger count;

- (NSEnumerator<KeyType> *)keyEnumerator;
- (nullable NSEnumerator<ObjectType> *)objectEnumerator;

- (void)removeAllObjects;

- (NSDictionary<KeyType, ObjectType> *)dictionaryRepresentation;  // create a dictionary of contents

@end

NS_ASSUME_NONNULL_END

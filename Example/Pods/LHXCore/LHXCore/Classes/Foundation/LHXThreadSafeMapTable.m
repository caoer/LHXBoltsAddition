//
//  LHXThreadSafeMapTable.m
//  Pods
//
//  Created by Zitao Xiong on 12/23/16.
//
//

#import "LHXThreadSafeMapTable.h"

@interface LHXThreadSafeMapTable ()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMapTable *mapTable;
- (instancetype)initCommon NS_DESIGNATED_INITIALIZER;
@end

@implementation LHXThreadSafeMapTable

- (instancetype)init {
    self = [self initCommon];
    if (self) {
        _mapTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:10];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self initCommon];
    if (self) {
        _mapTable = [[NSMapTable alloc] initWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_mapTable];
}

- (instancetype)initCommon {
    self = [super init];
    if (self) {
        NSString *uuid = [NSString stringWithFormat:@"com.lighthousex.ab.maptable_%p", self];
        _queue = dispatch_queue_create([uuid UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (instancetype)initWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions capacity:(NSUInteger)initialCapacity {
    self = [self initCommon];
    if (self) {
        _mapTable = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:valueOptions capacity:initialCapacity];
    }
    return self;
}

- (instancetype)initWithKeyPointerFunctions:(NSPointerFunctions *)keyFunctions valuePointerFunctions:(NSPointerFunctions *)valueFunctions capacity:(NSUInteger)initialCapacity {
    self = [self initCommon];
    if (self) {
        _mapTable = [[NSMapTable alloc] initWithKeyPointerFunctions:keyFunctions valuePointerFunctions:valueFunctions capacity:initialCapacity];
    }
    return self;
}

+ (NSMapTable *)mapTableWithKeyOptions:(NSPointerFunctionsOptions)keyOptions valueOptions:(NSPointerFunctionsOptions)valueOptions {
    return [[self alloc] initWithKeyOptions:keyOptions valueOptions:valueOptions capacity:10];
}

+ (NSMapTable *)strongToStrongObjectsMapTable {
    return [self mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
}

+ (NSMapTable *)weakToStrongObjectsMapTable {
    return [self mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
}

+ (NSMapTable *)strongToWeakObjectsMapTable {
    return [self mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
}

+ (NSMapTable *)weakToWeakObjectsMapTable {
    return [self mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
}

- (id)objectForKey:(id)aKey {
    __block id object;
    dispatch_sync(_queue, ^{
        object = [_mapTable objectForKey:aKey];
    });
    return object;
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_barrier_sync(_queue, ^{
        [self.mapTable removeObjectForKey:aKey];
    });
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    aKey = [aKey copyWithZone:NULL];
    dispatch_barrier_async(_queue, ^{
        [_mapTable setObject:anObject forKey:aKey];
    });
}

- (NSEnumerator  *)keyEnumerator {
    __block NSEnumerator *enu;
    dispatch_sync(_queue, ^{
        enu = [_mapTable keyEnumerator];
    });
    return enu;
}

- (NSEnumerator *)objectEnumerator {
    __block NSEnumerator *enu;
    dispatch_sync(_queue, ^{
        enu = [_mapTable objectEnumerator];
    });
    return enu;
}

- (void)removeAllObjects {
    dispatch_barrier_async(_queue, ^{
        [_mapTable removeAllObjects];
    });
}

- (NSDictionary *)dictionaryRepresentation {
    __block NSDictionary *dictionary;
    dispatch_sync(_queue, ^{
        dictionary = [_mapTable dictionaryRepresentation];
    });
    return dictionary;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id  _Nullable __unsafe_unretained [])buffer count:(NSUInteger)len {
    __block NSUInteger count;
    dispatch_sync(_queue, ^{
        count = [_mapTable countByEnumeratingWithState:state objects:buffer count:len];
    });
    return count;
}

- (id)copy {
    __block LHXThreadSafeMapTable *copyInstance;
    dispatch_sync(_queue, ^{
        copyInstance = [[self.class alloc] initCommon];
        copyInstance.mapTable = [_mapTable copy];
    });
    return copyInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return [self copy];
}
@end

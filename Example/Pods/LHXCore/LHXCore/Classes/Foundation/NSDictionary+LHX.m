//
//  NSDictionary+LHX.m
//  LHX
//

#import "NSDictionary+LHX.h"

@implementation NSDictionary (TMManipulationAdditions)

- (NSDictionary *)lhx_dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *result = [self mutableCopy];
    [result addEntriesFromDictionary:dictionary];
    return result;
}

- (NSDictionary *)lhx_dictionaryByRemovingValuesForKeys:(NSArray *)keys {
    NSMutableDictionary *result = [self mutableCopy];
    [result removeObjectsForKeys:keys];
    return result;
}

- (NSDictionary *)lhx_dictionaryByRemovingSameValueInDictionary:(NSDictionary *)dictionary {
    __block NSMutableDictionary *result = [self mutableCopy];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:dictionary[key]]) {
            [result removeObjectForKey:key];
        }
    }];
    
    return result;
}

+ (NSDictionary *)lhx_dictionaryByMerging:(NSDictionary *)dict1 with:(NSDictionary *)dict2 {
    if (!dict2) {
        return dict1;
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dict1];
    
    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj2, BOOL *stop) {
        if (![dict1 objectForKey:key]) {
            [result setObject:obj2 forKey:key];
        }
        else {
            //dict1 and dict2 both has key
            NSObject *obj1 = [dict1 objectForKey:key];
            //if class does not match, use dict2's value
            if (![obj1 isKindOfClass:[obj2 class]]) {
                [result setObject:obj2 forKey:key];
            }
            else {
                //if obj2 and obj1 are both dictionary, do deep merging
                if ([obj2 isKindOfClass:[NSDictionary class]]) {
                    [result setObject:[NSDictionary lhx_dictionaryByMerging:(NSDictionary *)obj1 with:(NSDictionary *)obj2] forKey:key];
                }
                else {
                    //for other type, including array, using obj2's value
                    [result setObject:obj2 forKey:key];
                }
            }
        }
    }];
    
    return result;
}

- (NSDictionary *)lhx_dictionaryByMergingWith:(NSDictionary *)dict {
    return [[self class] lhx_dictionaryByMerging:self with:dict];
}
@end


@implementation NSDictionary (KeyPath)
- (id)lhx_objectForKeyPath:(NSString *)keyPath {
    id object = self;
    NSArray *keyPaths = [keyPath componentsSeparatedByString:@"."];
    for (NSString *currentKeyPath in keyPaths) {
        if (![object isKindOfClass:[NSDictionary class]]) {
            object = nil;
        }
        
        object = [object objectForKey:currentKeyPath];
        
        if (object == nil) {
            break;
        }
    }
    return object;
}
@end

//
//  NSMutableDictionary+LHX.m
//  Pods
//
//  Created by Zitao Xiong on 12/18/16.
//
//

#import "NSMutableDictionary+LHX.h"

@implementation NSMutableDictionary (LightHouseX)
- (void)lhx_addEntriesFromDictionaryMergeFirst:(NSDictionary *)dictionary {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (!self[key]) {
            self[key] = obj;
        }
        else {
            if ([self[key] isKindOfClass:[NSMutableDictionary class]] && [obj isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mSelfObj = self[key];
                [mSelfObj lhx_addEntriesFromDictionaryMergeFirst:obj];
            }
            else if ([self[key] isKindOfClass:[NSDictionary class]] && [obj isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *mSelfObj = [self[key] mutableCopy];
                [mSelfObj lhx_addEntriesFromDictionaryMergeFirst:obj];
                self[key] = mSelfObj;
            }
            else {
                self[key] = obj;
            }
        }
    }];
}
@end

static NSString *const KeyPathDelimiter = @".";
@interface NestedObjectSetters : NSObject

+ (void)setObject:(id)object onObject:(id)target forKeyPath:(NSString *)keyPath createIntermediateDictionaries:(BOOL)createIntermediates replaceIntermediateObjects:(BOOL)replaceIntermediates;

@end

@implementation NestedObjectSetters

+ (void)setObject:(id)object onObject:(id)target forKeyPath:(NSString *)keyPath createIntermediateDictionaries:(BOOL)createIntermediates replaceIntermediateObjects:(BOOL)replaceIntermediates {
    
    if (!keyPath) {
        [NSException raise:NSInvalidArgumentException format:@"not keypath found"];
        return;
    }
    
    if ([keyPath rangeOfString:KeyPathDelimiter].location == NSNotFound) {
        [target setObject:object forKey:keyPath];
        return;
    }
    
    NSArray *pathComponents = [keyPath componentsSeparatedByString:KeyPathDelimiter];
    
    NSString *rootKey = [pathComponents objectAtIndex:0];
    
    NSMutableDictionary *replacementDict = [NSMutableDictionary dictionary];
    
    id previousObject = target;
    NSMutableDictionary *previousReplacement = replacementDict;
    
    BOOL reachedDictionaryLeaf = NO;
    
    for (NSString *path in pathComponents) {
        id currentObject = (reachedDictionaryLeaf) ? nil : [previousObject objectForKey:path];
        
        if (currentObject == nil) {
            reachedDictionaryLeaf = YES;
            
            if (createIntermediates) {
                NSMutableDictionary *newNode = [NSMutableDictionary dictionary];
                [previousReplacement setObject:newNode forKey:path];
                previousReplacement = newNode;
            } else {
                return;
            }
        } else if ([currentObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *newNode = [NSMutableDictionary dictionaryWithDictionary:currentObject];
            [previousReplacement setObject:newNode forKey:path];
            previousReplacement = newNode;
        } else {
            reachedDictionaryLeaf = YES;
            
            if (replaceIntermediates) {
                NSMutableDictionary *newNode = [NSMutableDictionary dictionary];
                [previousReplacement setObject:newNode forKey:path];
                previousReplacement = newNode;
            } else {
                return;
            }
        }
        
        previousObject = currentObject;
    }
    
    [replacementDict setValue:object forKeyPath:keyPath];
    
    [target setObject:[replacementDict objectForKey:rootKey] forKey:rootKey];
}

@end

@implementation NSMutableDictionary (NestedObjectSetters)

- (void)tm_setObject:(id)object forKeyPath:(NSString *)keyPath {
    [self tm_setObject:object forKeyPath:keyPath createIntermediateDictionaries:YES replaceIntermediateObjects:YES];
}

- (void)tm_setObject:(id)object forKeyPath:(NSString *)keyPath createIntermediateDictionaries:(BOOL)createIntermediates replaceIntermediateObjects:(BOOL)replaceIntermediates {
    [NestedObjectSetters setObject:object
                          onObject:self
                        forKeyPath:keyPath
    createIntermediateDictionaries:createIntermediates
        replaceIntermediateObjects:replaceIntermediates];
}


@end


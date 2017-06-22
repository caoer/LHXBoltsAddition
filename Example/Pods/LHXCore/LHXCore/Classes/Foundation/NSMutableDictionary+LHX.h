//
//  NSMutableDictionary+LHX.h
//  Pods
//
//  Created by Zitao Xiong on 12/18/16.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (LightHouseX)
- (void)lhx_addEntriesFromDictionaryMergeFirst:(NSDictionary *)dictionary;
@end

@interface NSMutableDictionary (KeyPath)
- (void)tm_setObject:(id)object forKeyPath:(NSString *)keyPath;
- (void)tm_setObject:(id)object forKeyPath:(NSString *)keyPath createIntermediateDictionaries:(BOOL)createIntermediates replaceIntermediateObjects:(BOOL)replaceIntermediates;
@end


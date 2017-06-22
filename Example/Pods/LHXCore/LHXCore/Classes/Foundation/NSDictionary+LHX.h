//
//  NSDictionary+LHX.h
//  LHX
//

#import "NSDictionary+LHXAddition.h"
#import "NSDictionary+LHX.h"

@interface NSDictionary (TMManipulationAdditions)

- (NSDictionary *)lhx_dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary;

/// Creates a new dictionary with all the entries for the given keys removed from
/// the receiver.
- (NSDictionary *)lhx_dictionaryByRemovingValuesForKeys:(NSArray *)keys;

//TODO: add recursive version
//#warning won't handle recursive now, need to add
//- (NSDictionary *)lhx_dictionaryByRemovingSameValueInDictionary:(NSDictionary *)dictionary;

//- (NSMutableDictionary *)tm_mutableDictionaryFromModelValue;

+ (NSDictionary *)lhx_dictionaryByMerging:(NSDictionary *)dict1 with:(NSDictionary *)dict2;
- (NSDictionary *)lhx_dictionaryByMergingWith:(NSDictionary *)dict;
@end

@interface NSDictionary (KeyPath)
- (id)lhx_objectForKeyPath:(NSString *)keyPath;
@end

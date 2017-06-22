//
//  BFTaskColdGenerator.h
//  Pods
//
//  Created by Zitao Xiong on 10/23/16.
//
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>

NS_ASSUME_NONNULL_BEGIN
@interface BFTaskColdGenerator : NSObject
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGeneratorBlock:(BFTask* (^)(void))generator;
- (BFTask *)task;
@end

@interface BFTask (ColdGenerator)
+ (instancetype)tasksForCompletionOfAllTasksSerialWithTaskGenerators:(NSArray<BFTaskColdGenerator *> *)taskGenerators;
@end
NS_ASSUME_NONNULL_END

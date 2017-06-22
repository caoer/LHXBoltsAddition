//
//  LHXAsyncTaskQueue.h
//  Pods
//
//  Created by Zitao Xiong on 10/23/16.
//
//

#import <Bolts/BFTask.h>

NS_ASSUME_NONNULL_BEGIN

@interface LHXAsyncTaskQueue : NSObject

+ (instancetype)taskQueue;

- (BFTask *)enqueue:(BFContinuationBlock)block;

@end

NS_ASSUME_NONNULL_END

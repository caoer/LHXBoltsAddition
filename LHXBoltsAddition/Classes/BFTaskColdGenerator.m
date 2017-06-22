//
//  BFTaskColdGenerator.m
//  Pods
//
//  Created by Zitao Xiong on 10/23/16.
//
//

#import "BFTaskColdGenerator.h"


@interface __XZTAsyncTaskQueue : NSObject

@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong) BFTask *tail;

@end

@implementation __XZTAsyncTaskQueue
///--------------------------------------
#pragma mark - Init
///--------------------------------------

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (!self) return nil;
    
    self.syncQueue = queue;
    _tail = [BFTask taskWithResult:nil];
    
    return self;
}

+ (instancetype)taskQueue {
    return [[self alloc] init];
}

///--------------------------------------
#pragma mark - Enqueue
///--------------------------------------

- (BFTask *)enqueue:(BFContinuationBlock)block {
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    dispatch_async(_syncQueue, ^{
        _tail = [_tail continueWithExecutor:[BFExecutor defaultExecutor] withBlock:block];
        [_tail continueWithExecutor:[BFExecutor defaultExecutor] withBlock:^id(BFTask *task) {
            if (task.faulted) {
                [source trySetError:task.error];
            } else if (task.cancelled) {
                [source trySetCancelled];
            } else {
                [source trySetResult:task.result];
            }
            return task;
        }];
    });
    return source.task;
}

@end

@interface BFTaskColdGenerator()
@property (nonatomic, copy) BFTask* (^generator)(void);
@end

@implementation BFTaskColdGenerator
- (instancetype)initWithGeneratorBlock:(BFTask *(^)(void))generator {
    self = [super init];
    if (self) {
        self.generator = generator;
    }
    return self;
}

- (BFTask *)task {
    return self.generator();
}
@end


@implementation BFTask (ColdGenerator)
+ (BFTask *)tasksForCompletionOfAllTasksSerialWithTaskGenerators:(NSArray<BFTaskColdGenerator *> *)taskGenerators {
    return [self tasksForCompletionOfAllTasksSerialWithTaskGenerators:taskGenerators queue:dispatch_get_main_queue()];
}

+ (BFTask *)tasksForCompletionOfAllTasksSerialWithTaskGenerators:(NSArray<BFTaskColdGenerator *> *)taskGenerators queue:(dispatch_queue_t)q {
    
    __XZTAsyncTaskQueue *queue = [[__XZTAsyncTaskQueue alloc] initWithQueue:q];
    
    __block BFTask *task;
    for (BFTaskColdGenerator *generator in taskGenerators) {
        task = [queue enqueue:^id _Nullable(BFTask * _Nonnull t) {
            return generator.task;
        }];
    }
    
    return task;
}

@end

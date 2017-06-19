//
//  AppBuilderMVP
//
//  Created by Zitao Xiong on 8/19/16.
//  Copyright © 2016 lighthousex. All rights reserved.
//

#import "BFTask+LighthouseX.h"
#import "LHXLog.h"

@implementation BFExecutor (Background)

+ (instancetype)defaultPriorityBackgroundExecutor {
    static BFExecutor *executor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        executor = [BFExecutor executorWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    });
    return executor;
}

@end

@implementation BFTask (LighthouseX)

+ (instancetype)nilTask {
    return [BFTask taskWithResult:nil];
}

- (BFTask *)continueAsyncWithBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor defaultPriorityBackgroundExecutor] withBlock:block];
}

- (BFTask *)continueAsyncWithSuccessBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor defaultPriorityBackgroundExecutor] withSuccessBlock:block];
}

- (BFTask *)continueImmediatelyWithBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor immediateExecutor] withBlock:block];
}

- (BFTask *)continueImmediatelyWithSuccessBlock:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor immediateExecutor] withSuccessBlock:block];
}

- (BFTask *)continueWithResult:(id)result {
    return [self continueWithBlock:^id(BFTask *task) {
        return result;
    }];
}

- (BFTask *)continueWithSuccessResult:(id)result {
    return [self continueWithSuccessBlock:^id(BFTask *task) {
        return result;
    }];
}

- (BFTask *)continueWithMainThreadResultBlock:(void (^)(_Nullable id object, NSError *_Nullable error))resultBlock {
    return [self continueWithMainThreadResultBlock:resultBlock executeIfCancelled:NO];
}

- (BFTask *)continueWithMainThreadResultBlock:(void (^)(_Nullable id object, NSError *_Nullable error))resultBlock
                           executeIfCancelled:(BOOL)executeIfCancelled {
    if (!resultBlock) {
        return self;
    }
    return [self continueWithExecutor:[BFExecutor mainThreadExecutor]
                            withBlock:^id(BFTask *task) {
                                BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
                                @try {
                                    if (!self.cancelled || executeIfCancelled) {
                                        resultBlock(self.result, self.error);
                                    }
                                } @finally {
                                    tcs.result = nil;
                                }
                                return tcs.task;
                            }];
}

- (BFTask *)continueWithMainThreadBooleanResultBlock:(void (^)(BOOL succeed, NSError *_Nullable error))resultBlock
                                  executeIfCancelled:(BOOL)executeIfCancelled {
    return [self continueWithMainThreadResultBlock:^(id object, NSError *error) {
        resultBlock([object boolValue], error);
    } executeIfCancelled:executeIfCancelled];
}

- (BFTask *)thenCallBackOnMainThreadAsync:(void(^)(id result, NSError *error))block {
    return [self continueWithMainThreadResultBlock:block executeIfCancelled:NO];
}

- (BFTask *)thenCallBackOnMainThreadWithBoolValueAsync:(void(^)(BOOL result, NSError *error))block {
    if (!block) {
        return self;
    }
    return [self thenCallBackOnMainThreadAsync:^(id blockResult, NSError *blockError) {
        block([blockResult boolValue], blockError);
    }];
}

- (id)waitForResult:(NSError **)error {
    return [self waitForResult:error withMainThreadWarning:YES];
}

- (id)waitForResult:(NSError **)error withMainThreadWarning:(BOOL)warningEnabled {
    if (warningEnabled) {
        [self waitUntilFinished];
    } else {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self continueWithBlock:^id(BFTask *task) {
            dispatch_semaphore_signal(semaphore);
            return nil;
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    if (self.cancelled) {
        return nil;
    }
    if (self.error && error) {
        *error = self.error;
    }
    return self.result;
}

- (BFTask *)continueWithErrorLogging {
    return [self continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.faulted || t.cancelled) {
            LHXLogError(@"task error: %@", t.error);
            return t;
        }
        else {
            return t.result;
        }
    }];
}
@end


@implementation BFTask (BoltsExtras)

- (instancetype)continueWithMainThread:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        return block(task);
    }];
}

- (instancetype)continueWithSuccessOnMainThread:(BFContinuationBlock)block {
    return [self continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id(BFTask *task) {
        return block(task);
    }];
    
}

- (BOOL)isSuccessful {
    if (self.isCompleted) {
        if ((self.error == nil) && (!self.cancelled)) {
            return YES;
        }
    }
    return NO;
}

- (id)debugQuickLookObject {
    if (self.isCompleted) {
        if (self.isCancelled) {
            return [NSString stringWithFormat:@"%@ CANCELED",self];
        }
        else if (self.error != nil) {
            return [NSString stringWithFormat:@"%@ COMPLETED WITH ERROR:%@",self,[self.error localizedDescription]];
        }
        else if (self.result != nil) {
            return [NSString stringWithFormat:@"%@ COMPLETED WITH RESULT:[%@]",self,self.result];
        }
        else {
            return [NSString stringWithFormat:@"%@ COMPLETED",self];
        }
    }
    else {
        return [NSString stringWithFormat:@"%@ NOT COMPLETED YET",self];
    }
}
@end

void forceLoadCategory_BFTask_Private() {
    NSString *string = nil;
    [string description];
}

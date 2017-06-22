#ifndef LHXAssert_h
#define LHXAssert_h

#import <Foundation/Foundation.h>
#import "LHXMacros.h"

extern NSString * const LHXErrorDomain;

#define LHXAssertNil(condition, description, ...) NSAssert(!(condition), (description), ##__VA_ARGS__)
#define LHXCAssertNil(condition, description, ...) NSCAssert(!(condition), (description), ##__VA_ARGS__)

#define LHXAssertNotNil(condition, description, ...) NSAssert((condition), (description), ##__VA_ARGS__)
#define LHXCAssertNotNil(condition, description, ...) NSCAssert((condition), (description), ##__VA_ARGS__)

/**
 Raises an `NSInvalidArgumentException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define LHXClassTypeAssert(instance, klass) \
do {\
    if (!([instance isKindOfClass:klass])) { \
        [NSException raise:NSInvalidArgumentException \
            format:@"expect class: %@, but got %@", klass, [instance class]]; \
    } \
} while(0)

#define LHXProtocolAssert(instance, protocol) \
do {\
    if (!([instance conformsToProtocol:protocol])) { \
        [NSException raise:NSInvalidArgumentException \
            format:@"expect class conforms to protocol: %@, but %@ did not", protocol, [instance class]]; \
    } \
} while(0)

/**
 Raises an `NSInvalidArgumentException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define LHXParameterAssert(condition, description, ...) \
do {\
    if (!(condition)) { \
        [NSException raise:NSInvalidArgumentException \
            format:description, ##__VA_ARGS__]; \
    } \
} while(0)

#define LHXParameterAssertNotNil(condition) \
do {\
    if (!(condition)) { \
        [NSException raise:NSInvalidArgumentException \
            format:@STRINGIFY(condition) " should not be nil"]; \
    } \
} while(0)

/**
 Raises an `NSInvalidArgumentException`. Use `description` to supply the way to fix the exception.
 */
#define LHXParameterAssertionFailure(description, ...) \
do {\
    [NSException raise:NSInvalidArgumentException \
        format:description, ##__VA_ARGS__]; \
} while(0)

/**
 Raises an `NSRangeException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define LHXRangeAssert(condition, description, ...) \
do {\
    if (!(condition)) { \
        [NSException raise:NSRangeException \
            format:description, ##__VA_ARGS__]; \
    } \
} while(0)

/**
 Raises an `NSInternalInconsistencyException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define LHXConsistencyAssert(condition, description, ...) \
do { \
    if (!(condition)) { \
        [NSException raise:NSInternalInconsistencyException \
            format:description, ##__VA_ARGS__]; \
    } \
} while(0)

/**
 Raises an `NSInternalInconsistencyException`. Use `description` to supply the way to fix the exception.
 */
#define LHXConsistencyAssertionFailure(description, ...) \
do {\
    [NSException raise:NSInternalInconsistencyException \
        format:description, ##__VA_ARGS__]; \
} while(0)

/**
 Always raises `NSInternalInconsistencyException` with details
 about the method used and class that received the message
 */
#define LHXNotDesignatedInitializer() \
do { \
    LHXConsistencyAssertionFailure(@"%@ is not the designated initializer for instances of %@.", \
        NSStringFromSelector(_cmd), \
        NSStringFromClass([self class])); \
    return nil; \
} while (0)

/**
 Raises `NSInternalInconsistencyException` if current thread is not main thread.
 */
#define LHXAssertMainThread() \
do { \
    LHXConsistencyAssert([NSThread isMainThread], @"This method must be called on the main thread."); \
} while (0)

/**
 Raises `NSInternalInconsistencyException` if current thread is not the required one.
 */
#define LHXAssertIsOnThread(thread) \
do { \
    LHXConsistencyAssert([NSThread currentThread] == thread, \
        @"This method must be called only on thread: %@.", thread); \
} while (0)

/**
 Raises `NSInternalInconsistencyException` if the current queue
 is not the same as the queue provided.
 Make sure you mark the queue first via `TMMarkDispatchQueue`
 */
#define LHXAssertIsOnDispatchQueue(queue) \
do { \
    void *mark = TMOSObjectPointer(queue); \
    LHXConsistencyAssert(dispatch_get_specific(mark) == mark, \
        @"%s must be executed on %s", \
        __PRETTY_FUNCTION__, dispatch_queue_get_label(queue)); \
} while (0)

#pragma mark - Javascript

#define LHX_BRIDGE_THREAD_NAME @"com.lighthousex.beacon.bridge"

#define LHXAssertBridgeThread() \
LHXParameterAssert([[NSThread currentThread].name isEqualToString:LHX_BRIDGE_THREAD_NAME], \
@"must be called on the bridge thread")

TM_EXTERN NSString *LHXCurrentThreadName(void);

/**
 * Convenience macro to assert which thread is currently running (DEBUG mode only)
 */
#if DEBUG

#define LHXAssertThread(thread, format...) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"") \
LHXParameterAssert( \
    [(id)thread isKindOfClass:[NSString class]] ? \
        [LHXCurrentThreadName() isEqualToString:(NSString *)thread] : \
            [(id)thread isKindOfClass:[NSThread class]] ? \
                [NSThread currentThread] ==  (NSThread *)thread : \
                dispatch_get_current_queue() == (dispatch_queue_t)thread, \
        format); \
_Pragma("clang diagnostic pop")

#else

#define LHXAssertThread(thread, format...) do { } while (0)

#endif

#endif


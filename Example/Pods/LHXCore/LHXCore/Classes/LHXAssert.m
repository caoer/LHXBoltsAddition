#import "LHXAssert.h"
#import "LHXHelper.h"

NSString *LHXCurrentThreadName(void) {
    NSThread *thread = [NSThread currentThread];
    NSString *threadName = LHXIsMainQueue() || thread.isMainThread ? @"main" : thread.name;
    if (threadName.length == 0) {
        const char *label = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
        if (label && strlen(label) > 0) {
            threadName = @(label);
        } else {
            threadName = [NSString stringWithFormat:@"%p", thread];
        }
    }
    return threadName;
}

//
//  LHXLog.h
//  Pods
//
//  Created by Zitao Xiong on 12/19/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LHXLogFlag) {
    LHXLogFlagError      = 1 << 0,
    LHXLogFlagWarning    = 1 << 1,
    LHXLogFlagInfo       = 1 << 2,
    LHXLogFlagLog        = 1 << 3,
    LHXLogFlagDebug      = 1 << 4
};

/**
 *  Use Log levels to filter logs.
 */
typedef NS_ENUM(NSUInteger, LHXLogLevel){
    /**
     *  No logs
     */
    LHXLogLevelOff       = 0,
    
    /**
     *  Error only
     */
    LHXLogLevelError     = LHXLogFlagError,
    
    /**
     *  Error and warning
     */
    LHXLogLevelWarning   = LHXLogLevelError | LHXLogFlagWarning,
    
    /**
     *  Error, warning and info
     */
    LHXLogLevelInfo      = LHXLogLevelWarning | LHXLogFlagInfo,
    
    /**
     *  Log, warning info
     */
    LHXLogLevelLog       = LHXLogFlagLog | LHXLogLevelInfo,
    
    /**
     *  Error, warning, info and debug logs
     */
    LHXLogLevelDebug     = LHXLogLevelLog | LHXLogFlagDebug,
    
    /**
     *  All
     */
    LHXLogLevelAll       = NSUIntegerMax
};

/**
 *  External log protocol, which is used to output the log to the external.
 */
@protocol LHXLogProtocol <NSObject>

@required

/**
 * External log level.
 */
- (LHXLogLevel)logLevel;

- (void)log:(LHXLogFlag)flag message:(NSString *)message;

@end

@interface LHXLogger : NSObject


/**
 get current log level

 @return log level
 */
+ (LHXLogLevel)logLevel;

+ (void)setLogLevel:(LHXLogLevel)level;

+ (NSString *)logLevelString;

+ (void)setLogLevelString:(NSString *)levelString;

//+ (void)log:(LHXLogFlag)flag file:(const char *)fileName line:(NSUInteger)line format:(NSString *)format, ... NS_FORMAT_FUNCTION(4,5);

+ (void)log:(LHXLogFlag)flag file:(const char *)fileName line:(NSUInteger)line message:(NSString *)message;

+ (void)devLog:(LHXLogFlag)flag file:(const char *)fileName line:(NSUInteger)line format:(NSString *)format, ... NS_FORMAT_FUNCTION(4,5);

+ (void)registerExternalLog:(id<LHXLogProtocol>)externalLog;

+ (void)removeExternalLog:(id<LHXLogProtocol>)externalLog;
@end

#define LHX_FILENAME (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)


#define LHX_LOG(flag, fmt, ...)          \
do {                                    \
[LHXLogger devLog:flag                     \
file:LHX_FILENAME              \
line:__LINE__                 \
format:(fmt), ## __VA_ARGS__];  \
} while(0)

extern void _LHXLogObjectsImpl(NSString *severity, NSArray *arguments);

#define LHXLog(format,...)               LHX_LOG(LHXLogFlagLog, format, ##__VA_ARGS__)
#define LHXLogDebug(format, ...)         LHX_LOG(LHXLogFlagDebug, format, ##__VA_ARGS__)
#define LHXLogInfo(format, ...)          LHX_LOG(LHXLogFlagInfo, format, ##__VA_ARGS__)
#define LHXLogWarning(format, ...)       LHX_LOG(LHXLogFlagWarning, format ,##__VA_ARGS__)
#define LHXLogError(format, ...)         LHX_LOG(LHXLogFlagError, format, ##__VA_ARGS__)

#ifndef LHXConditionalLog
#define LHXConditionalLog
/**
 Raises an `NSInvalidArgumentException` if the `condition` does not pass.
 Use `description` to supply the way to fix the exception.
 */
#define LHXParameterLogWarning(condition, description, ...) \
do {\
if (!(condition)) { \
       LHXLogWarning(description, ##__VA_ARGS__); \
    } \
} while(0)
#endif

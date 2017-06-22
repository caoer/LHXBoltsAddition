//
//  LHXLog.m
//  Pods
//
//  Created by Zitao Xiong on 12/19/16.
//
//

#import "LHXLog.h"

// Xcode does NOT natively support colors in the Xcode debugging console.
// You'll need to install the XcodeColors plugin to see colors in the Xcode console.
// https://github.com/robbiehanson/XcodeColors
//
// The following is documentation from the XcodeColors project:
//
//
// How to apply color formatting to your log statements:
//
// To set the foreground color:
// Insert the ESCAPE_SEQ into your string, followed by "fg124,12,255;" where r=124, g=12, b=255.
//
// To set the background color:
// Insert the ESCAPE_SEQ into your string, followed by "bg12,24,36;" where r=12, g=24, b=36.
//
// To reset the foreground color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "fg;"
//
// To reset the background color (to default value):
// Insert the ESCAPE_SEQ into your string, followed by "bg;"
//
// To reset the foreground and background color (to default values) in one operation:
// Insert the ESCAPE_SEQ into your string, followed by ";"

#define XCODE_COLORS_ESCAPE_SEQ "\033["

#define XCODE_COLORS_RESET_FG   XCODE_COLORS_ESCAPE_SEQ "fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG   XCODE_COLORS_ESCAPE_SEQ "bg;" // Clear any background color
#define XCODE_COLORS_RESET      XCODE_COLORS_ESCAPE_SEQ ";"  // Clear any foreground or background color

#define GraceLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


#ifdef DEBUG
static const LHXLogLevel defaultLogLevel = LHXLogLevelInfo;
#else
static const LHXLogLevel defaultLogLevel = LHXLogLevelWarning;
#endif

static NSMutableSet<id<LHXLogProtocol>> *_externalLoggers;

@implementation LHXLogger {
    LHXLogLevel _logLevel;
}

+ (instancetype)sharedInstance {
    static LHXLogger *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance->_logLevel = defaultLogLevel;
        _externalLoggers = [NSMutableSet set];
    });
    return _sharedInstance;
}

+ (void)setLogLevel:(LHXLogLevel)level {
    if (((LHXLogger*)[self sharedInstance])->_logLevel != level) {
        ((LHXLogger*)[self sharedInstance])->_logLevel = level;
        
        //        [[LHXSDKManager bridgeManager] resetEnvironment];
    }
}

+ (LHXLogLevel)logLevel {
    return ((LHXLogger*)[self sharedInstance])->_logLevel;
}

+ (NSString *)logLevelString {
    NSDictionary *logLevelEnumToString =
    @{
      @(LHXLogLevelOff) : @"off",
      @(LHXLogLevelError) : @"error",
      @(LHXLogLevelWarning) : @"warn",
      @(LHXLogLevelInfo) : @"info",
      @(LHXLogLevelLog) : @"log",
      @(LHXLogLevelDebug) : @"debug",
      @(LHXLogLevelAll) : @"debug"
      };
    return [logLevelEnumToString objectForKey:@([self logLevel])];
}

+ (void)setLogLevelString:(NSString *)levelString {
    NSDictionary *logLevelStringToEnum =
    @{
      @"all" : @(LHXLogLevelAll),
      @"error" : @(LHXLogLevelError),
      @"warn" : @(LHXLogLevelWarning),
      @"info" : @(LHXLogLevelInfo),
      @"debug" : @(LHXLogLevelDebug),
      @"log" : @(LHXLogLevelLog)
      };
    
    [self setLogLevel:[logLevelStringToEnum[levelString] unsignedIntegerValue]];
}

+ (void)log:(LHXLogFlag)flag file:(const char *)fileName line:(NSUInteger)line message:(NSString *)message {
    NSString *flagString;
    NSString *flagColor;
    switch (flag) {
        case LHXLogFlagError: {
            flagString = @"error";
            flagColor = @"fg255,0,0;";
        }
            break;
        case LHXLogFlagWarning:
            flagString = @"warn";
            flagColor = @"fg255,165,0;";
            break;
        case LHXLogFlagDebug:
            flagString = @"debug";
            flagColor = @"fg0,128,0;";
            break;
        case LHXLogFlagLog:
            flagString = @"log";
            flagColor = @"fg128,128,128;";
            break;
        default:
            flagString = @"info";
            flagColor = @"fg100,149,237;";
            break;
    }
    
    if (_externalLoggers.count) {
        NSString *logMessage = [NSString stringWithFormat:@"%s:%ld, %@", fileName, (unsigned long)line, message];
        
        [_externalLoggers enumerateObjectsUsingBlock:^(id<LHXLogProtocol>  _Nonnull _externalLog, BOOL * _Nonnull stop) {
            if ([_externalLog logLevel] & flag) {
                [_externalLog log:flag message:logMessage];
            }
        }];
    }
    
    if ([LHXLogger logLevel] & flag) {
        NSString *logMessage = [NSString stringWithFormat:@"%s%@ [%@]%s:%ld, %@ %s", XCODE_COLORS_ESCAPE_SEQ, flagColor, flagString, fileName, (unsigned long)line, message, XCODE_COLORS_RESET];
        GraceLog(@"%@", logMessage);
    }
}

+ (void)devLog:(LHXLogFlag)flag file:(const char *)fileName line:(NSUInteger)line format:(NSString *)format, ... {
    __block BOOL shouldCallExternalLog = NO;
    [_externalLoggers enumerateObjectsUsingBlock:^(id<LHXLogProtocol>  _Nonnull _externalLog, BOOL * _Nonnull stop) {
        if ( [_externalLog logLevel] & flag) {
            shouldCallExternalLog = YES;
            *stop = YES;
        }
    }];
    if ([LHXLogger logLevel] & flag ||shouldCallExternalLog) {
        if (!format) {
            return;
        }
        NSString *flagString = @"log";
        switch (flag) {
            case LHXLogFlagError:
                flagString = @"error";
                break;
            case LHXLogFlagWarning:
                flagString = @"warn";
                break;
            case LHXLogFlagDebug:
                flagString = @"debug";
                break;
            case LHXLogFlagLog:
                flagString = @"log";
                break;
            default:
                flagString = @"info";
                break;
        }
        
        va_list args;
        va_start(args, format);
        NSString *message;
        //        @try {
        message = [[NSString alloc] initWithFormat:format arguments:args];
        //        } @catch (NSException *exception) {
        //           message = @"log message error";
        //        }
        va_end(args);
        
        NSArray *messageAry = [NSArray arrayWithObjects:message, nil];
        Class LHXLogClass = NSClassFromString(@"LHXDebugger");
        if (LHXLogClass) {
            SEL selector = NSSelectorFromString(@"coutLogWithLevel:arguments:");
            NSMethodSignature *methodSignature = [LHXLogClass instanceMethodSignatureForSelector:selector];
            if (methodSignature == nil) {
                NSString *info = [NSString stringWithFormat:@"%@ not found", NSStringFromSelector(selector)];
                [NSException raise:@"Method invocation appears abnormal" format:info, nil];
            }
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setTarget:[LHXLogClass alloc]];
            [invocation setSelector:selector];
            [invocation setArgument:&flagString atIndex:2];
            [invocation setArgument:&messageAry atIndex:3];
            [invocation invoke];
        }
        
        [self log:flag file:fileName line:line message:message];
    }
}

#pragma mark - External Log

+ (void)registerExternalLog:(id<LHXLogProtocol>)externalLog {
    [_externalLoggers addObject:externalLog];
}

+ (void)removeExternalLog:(id<LHXLogProtocol>)externalLog {
    [_externalLoggers removeObject:externalLog];
}

@end


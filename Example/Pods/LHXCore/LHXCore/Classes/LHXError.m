//
//  LHXError.m
//  Pods
//
//  Created by Zitao Xiong on 1/5/17.
//
//

#import "LHXError.h"


@implementation LHXError

@end

@implementation NSError (LHXError)

+ (NSError *)lhx_errorWithMessage:(NSString *)message {
    return [self lhx_errorWithMessage:message domain:LHXErrorDomain code:LHXErrorCodeUnspecified];
}

+ (NSError *)lhx_errorWithMessage:(NSString *)message domain:(NSString *)domain {
    return [self lhx_errorWithMessage:message domain:domain code:LHXErrorCodeUnspecified];
}

+ (NSError *)lhx_errorWithMessage:(NSString *)message domain:(NSString *)domain code:(NSInteger)code {
    return [NSError errorWithDomain:domain code:code userInfo:@{
                                                                NSLocalizedDescriptionKey: message
                                                                }];
}


@end

NSString * const LHXErrorDomain = @"LHXErrorDomain";
NSString * const LHXErrorUnspecified = @"Error Unspecified";

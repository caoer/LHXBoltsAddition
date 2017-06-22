//
//  LHXError.h
//  Pods
//
//  Created by Zitao Xiong on 1/5/17.
//
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LHXErrorCode) {
    LHXErrorCodeUnspecified = -8663,
};

extern NSString * const LHXErrorDomain;
extern NSString * const LHXErrorUnspecified;

@interface LHXError : NSObject
@end

@interface NSError (LHXError)
+ (NSError *)lhx_errorWithMessage:(NSString *)message;
+ (NSError *)lhx_errorWithMessage:(NSString *)message domain:(NSString *)domain;
+ (NSError *)lhx_errorWithMessage:(NSString *)message domain:(NSString *)domain code:(NSInteger)code;
@end

NS_ASSUME_NONNULL_END;

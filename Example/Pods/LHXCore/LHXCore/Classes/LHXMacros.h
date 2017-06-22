//
//  LHXMacros.h
//  Pods
//
//  Created by Zitao Xiong on 5/5/15.
//
//
#import <UIKit/UIKit.h>
#import <sys/time.h>
#import <pthread.h>
#import "metamacros.h"

#import "LHXLog.h"

#ifndef Pods_LHXMacros_h
#define Pods_LHXMacros_h


#if defined(__cplusplus)
    #define TM_EXTERN extern "C" __attribute__((visibility("default")))
#else
    #define TM_EXTERN extern __attribute__((visibility("default")))
#endif

#if __has_feature(objc_generics)
#   define __GENERICS(class, ...)      class<__VA_ARGS__>
#   define __GENERICS_TYPE(type)       type
#else
#   define __GENERICS(class, ...)      class
#   define __GENERICS_TYPE(type)       id
#endif

/**
 This exists because if we throw an exception from dispatch_sync, it doesn't 'bubble up' to the calling thread.
 This simply wraps dispatch_sync and properly throws the exception back to the calling thread, not the thread that
 the exception was originally raised on.

 @param queue The queue to execute on
 @param block The block to execute

 @see dispatch_sync
 */
#define LHX_sync_with_throw(queue, block)      \
    do {                                      \
        __block NSException *caught = nil;    \
        dispatch_sync(queue, ^{              \
            @try { block(); }                 \
            @catch (NSException *ex) {        \
                caught = ex;                  \
            }                                 \
        });                                   \
        if (caught) @throw caught;            \
    } while (0)

// Convert nil values to NSNull, and vice-versa
#define LHXNullIfNil(value) (value ?: (id)kCFNull)
#define LHXNilIfNull(value) (value == (id)kCFNull ? nil : value)

///--------------------------------------
#pragma mark - Runtime
///--------------------------------------

/**
 Using objc_msgSend directly is bad, very bad. Doing so without casting could result in stack-smashing on architectures
 (*cough* x86 *cough*) that use strange methods of returning values of different types.
 
 The objc_msgSend_safe macro ensures that we properly cast the function call to use the right conventions when passing
 parameters and getting return values. This also fixes some issues with ARC and objc_msgSend directly, though strange
 things can happen when receiving values from NS_RETURNS_RETAINED methods.
 */
#define objc_msgSend(...)  _Pragma("GCC error \"Use objc_msgSend_safe() instead!\"")
#define objc_msgSend_safe(returnType, argTypes...) ((returnType (*)(id, SEL, ##argTypes))(objc_msgSend))

/**
 Synthsize a dynamic object property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @param association  ASSIGN / RETAIN / COPY / RETAIN_NONATOMIC / COPY_NONATOMIC
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
     @interface NSObject (MyAdd)
     @property (nonatomic, retain) UIColor *myColor;
     @end
     
     #import <objc/runtime.h>
     @implementation NSObject (MyAdd)
     LHXSYNTH_DYNAMIC_PROPERTY_OBJECT(myColor, setMyColor, RETAIN, UIColor *)
     @end
 */
#ifndef LHXSYNTH_DYNAMIC_PROPERTY_OBJECT
#define LHXSYNTH_DYNAMIC_PROPERTY_OBJECT(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif

//same from above but no KVO
#ifndef LHXSYNTH_DYNAMIC_PROPERTY_OBJECT_NO_KVO
#define LHXSYNTH_DYNAMIC_PROPERTY_OBJECT_NO_KVO(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_)object { \
    objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
} \
- (_type_)_getter_ { \
    return objc_getAssociatedObject(self, @selector(_setter_:)); \
}
#endif

//     LHXSYNTH_DYNAMIC_PROPERTY_OBJECT_AUTO_CREATION(myColor, setMyColor, RETAIN, UIColor)
//Lazy creation
#ifndef LHXSYNTH_DYNAMIC_PROPERTY_OBJECT_AUTO_CREATION
#define LHXSYNTH_DYNAMIC_PROPERTY_OBJECT_AUTO_CREATION(_getter_, _setter_, _association_, _type_) \
- (void)_setter_ : (_type_ *)object { \
    [self willChangeValueForKey:@#_getter_]; \
    objc_setAssociatedObject(self, _cmd, object, OBJC_ASSOCIATION_ ## _association_); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_ *)_getter_ { \
    _type_ * object = objc_getAssociatedObject(self, @selector(_setter_:)); \
    if (!object) { \
        object = [[_type_ alloc] init]; \
        [self _setter_ : object]; \
    } \
    return object; \
}
#endif


//#define LHX_SYNTH_DICTIONARY_PROPERTY(_getter_, _setter_, _type_) \
//- (void)_setter_ : (_type_)object { \
//    self[@#_getter_] = object; \
//}\
//- (_type_)_getter_ { \
//    return self[@#_getter_]; \
//}

/**
 Synthsize a dynamic c type property in @implementation scope.
 It allows us to add custom properties to existing classes in categories.
 
 @warning #import <objc/runtime.h>
 *******************************************************************************
 Example:
     @interface NSObject (MyAdd)
     @property (nonatomic, retain) CGPoint myPoint;
     @end
     
     #import <objc/runtime.h>
     @implementation NSObject (MyAdd)
     LHXSYNTH_DYNAMIC_PROPERTY_CTYPE(myPoint, setMyPoint, CGPoint)
     @end
 */
#ifndef LHXSYNTH_DYNAMIC_PROPERTY_CTYPE
#define LHXSYNTH_DYNAMIC_PROPERTY_CTYPE(_getter_, _setter_, _type_) \
- (void)_setter_ : (_type_)object { \
    [self willChangeValueForKey:@#_getter_]; \
    NSValue *value = [NSValue value:&object withObjCType:@encode(_type_)]; \
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN); \
    [self didChangeValueForKey:@#_getter_]; \
} \
- (_type_)_getter_ { \
    _type_ cValue = { 0 }; \
    NSValue *value = objc_getAssociatedObject(self, @selector(_setter_:)); \
    [value getValue:&cValue]; \
    return cValue; \
}
#endif


/**
 Synthsize a weak or strong reference.
 
 Example:
    @weakify(self)
    [self doSomething^{
        @strongify(self)
        if (!self) return;
        ...
    }];
 */
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


/**
 Profile time cost.
 @param block    code to benchmark
 @param complete code time cost (millisecond)
 
 Usage:
    LHXBenchmark(^{
        // code
    }, ^(double ms) {
        NSLog("time cost: %.2f ms",ms);
    });
 
 */
static inline void LHXBenchmark(void (^block)(void), void (^complete)(double ms)) {
    // <QuartzCore/QuartzCore.h> version
    /*
    extern double CACurrentMediaTime (void);
    double begin, end, ms;
    begin = CACurrentMediaTime();
    block();
    end = CACurrentMediaTime();
    ms = (end - begin) * 1000.0;
    complete(ms);
    */
    
    // <sys/time.h> version
    struct timeval t0, t1;
    gettimeofday(&t0, NULL);
    block();
    gettimeofday(&t1, NULL);
    double ms = (double)(t1.tv_sec - t0.tv_sec) * 1e3 + (double)(t1.tv_usec - t0.tv_usec) * 1e-3;
    complete(ms);
}

static inline NSDate *_LHXCompileTime(const char *data, const char *time) {
    NSString *timeStr = [NSString stringWithFormat:@"%s %s",data,time];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd yyyy HH:mm:ss"];
    [formatter setLocale:locale];
    return [formatter dateFromString:timeStr];
}


/**
 Get compile timestamp.
 @return A new date object set to the compile date and time.
 */
#ifndef LHXCompileTime
// use macro to avoid compile warning when use pch file
#define LHXCompileTime() _LHXCompileTime(__DATE__, __TIME__)
#endif

#if !defined(LHX_INLINE)
#  if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#    define LHX_INLINE static inline
#  elif defined(__cplusplus)
#    define LHX_INLINE static inline
#  elif defined(__GNUC__)
#    define LHX_INLINE static __inline__
#  else
#    define LHX_INLINE static
#  endif
#endif

/*
 * Helpers for completions which call the block only if non-nil
 *
 */
#define LHX_BLOCK_EXEC(block, ...) if (block) { block(__VA_ARGS__); };

#define LHX_DISPATCH_EXEC(queue, block, ...) if (block) { dispatch_async(queue, ^{ block(__VA_ARGS__); } ); }

#define STRINGIFY2( x) #x
#define STRINGIFY(x) STRINGIFY2(x)

#define LHXIMPLStringKey(x) NSString *const x = @STRINGIFY(x)
#define LHXDefineStringKey(x) extern NSString *const x

#define LHXSuppressPerformSelectorWarning(PerformCall) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
        PerformCall; \
    _Pragma("clang diagnostic pop") \
} while (0)


/**
 Add this macro before each category implementation, so we don't have to use
 -all_load or -force_load to load object files from static libraries that only
 contain categories and no classes.
 More info: http://developer.apple.com/library/mac/#qa/qa2006/qa1490.html .
 *******************************************************************************
 Example:
     LHXSYNTH_DUMMY_CLASS(NSString_TMAdd)
 */
#ifndef LHXSYNTH_DUMMY_CLASS
#define LHXSYNTH_DUMMY_CLASS(_name_) \
@interface LHXSYNTH_DUMMY_CLASS_ ## _name_ : NSObject @end \
@implementation LHXSYNTH_DUMMY_CLASS_ ## _name_ @end
#endif


/**
 * \@keypath allows compile-time verification of key paths. Given a real object
 * receiver and key path:
 *
 * @code
 NSString *UTF8StringPath = @keypath(str.lowercaseString.UTF8String);
 // => @"lowercaseString.UTF8String"
 NSString *versionPath = @keypath(NSObject, version);
 // => @"version"
 NSString *lowercaseStringPath = @keypath(NSString.new, lowercaseString);
 // => @"lowercaseString"
 * @endcode
 *
 * ... the macro returns an \c NSString containing all but the first path
 * component or argument (e.g., @"lowercaseString.UTF8String", @"version").
 *
 * In addition to simply creating a key path, this macro ensures that the key
 * path is valid at compile-time (causing a syntax error if not), and supports
 * refactoring, such that changing the name of the property will also update any
 * uses of \@keypath.
 */
#ifndef keypath
#define keypath(...) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-repeated-use-of-weak\"") \
metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(keypath1(__VA_ARGS__))(keypath2(__VA_ARGS__)) \
_Pragma("clang diagnostic pop") \

#define keypath1(PATH) \
(((void)(NO && ((void)PATH, NO)), \
({ char *__extobjckeypath__ = strchr(# PATH, '.'); NSCAssert(__extobjckeypath__, @"Provided key path is invalid."); __extobjckeypath__ + 1; })))

#define keypath2(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))
#endif


/*
 * Concatenate preprocessor tokens a and b without expanding macro definitions
 * (however, if invoked from a macro, macro arguments are expanded).
 */
#define LHX_CONCAT(a, b)   a ## b
/*
 * Concatenate preprocessor tokens a and b after macro-expanding them.
 */
#define LHX_CONCAT_WRAPPER(a, b)    LHX_CONCAT(a, b)

/**
 * \@collectionKeypath allows compile-time verification of key paths across collections NSArray/NSSet etc. Given a real object
 * receiver, collection object receiver and related keypaths:
 *
 * @code
 
 NSString *employeesFirstNamePath = @collectionKeypath(department.employees, Employee.new, firstName)
 // => @"employees.firstName"
 
 NSString *employeesFirstNamePath = @collectionKeypath(Department.new, employees, Employee.new, firstName)
 // => @"employees.firstName"
 * @endcode
 *
 */
#ifndef collectionKeypath
#define collectionKeypath(...) \
metamacro_if_eq(3, metamacro_argcount(__VA_ARGS__))(collectionKeypath3(__VA_ARGS__))(collectionKeypath4(__VA_ARGS__))

#define collectionKeypath3(PATH, COLLECTION_OBJECT, COLLECTION_PATH) ([[NSString stringWithFormat:@"%s.%s",keypath(PATH), keypath(COLLECTION_OBJECT, COLLECTION_PATH)] UTF8String])

#define collectionKeypath4(OBJ, PATH, COLLECTION_OBJECT, COLLECTION_PATH) ([[NSString stringWithFormat:@"%s.%s",keypath(OBJ, PATH), keypath(COLLECTION_OBJECT, COLLECTION_PATH)] UTF8String])

#endif

#define LHX_ENUMBER_CASE(_invoke, idx, code, obj, _type, op, _flist) \
case code:{\
    _type *_tmp = malloc(sizeof(_type));\
    memset(_tmp, 0, sizeof(_type));\
    *_tmp = [obj op];\
    [_invoke setArgument:_tmp atIndex:(idx) + 2];\
    *(_flist + idx) = _tmp;\
    break;\
}
#define LHX_EPCHAR_CASE(_invoke, idx, code, obj, _type, op, _flist) \
case code:{\
    _type *_tmp = (_type  *)[obj op];\
    [_invoke setArgument:&_tmp atIndex:(idx) + 2];\
    *(_flist + idx) = 0;\
    break;\
}\

#define LHX_ALLOC_FLIST(_ppFree, _count) \
do {\
    _ppFree = (void *)malloc(sizeof(void *) * (_count));\
    memset(_ppFree, 0, sizeof(void *) * (_count));\
} while(0)

#define LHX_FREE_FLIST(_ppFree, _count) \
do {\
    for(int i = 0; i < _count; i++){\
        if(*(_ppFree + i ) != 0) {\
            free(*(_ppFree + i));\
        }\
    }\
    free(_ppFree);\
}while(0)

#define LHX_ARGUMENTS_SET(_invocation, _sig, idx, _obj, _ppFree) \
do {\
    const char *encode = [_sig getArgumentTypeAtIndex:(idx) + 2];\
    switch(encode[0]){\
        LHX_EPCHAR_CASE(_invocation, idx, _C_CHARPTR, _obj, char *, UTF8String, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_INT, _obj, int, intValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_SHT, _obj, short, shortValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_LNG, _obj, long, longValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_LNG_LNG, _obj, long long, longLongValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_UCHR, _obj, unsigned char, unsignedCharValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_UINT, _obj, unsigned int, unsignedIntValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_USHT, _obj, unsigned short, unsignedShortValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_ULNG, _obj, unsigned long, unsignedLongValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_ULNG_LNG, _obj,unsigned long long, unsignedLongLongValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_FLT, _obj, float, floatValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_DBL, _obj, double, doubleValue, _ppFree)\
        LHX_ENUMBER_CASE(_invocation, idx, _C_BOOL, _obj, bool, boolValue, _ppFree)\
        default: { [_invocation setArgument:&_obj atIndex:(idx) + 2]; *(_ppFree + idx) = 0; break;}\
    }\
}while(0)


#define LHXCheckLogError(error, abort) \
if (error) { \
    LHXLogError(@"error[%@]:%@", NSStringFromSelector(_cmd), error); \
    if (abort) { \
        return; \
    }\
}

static inline NSString *LHXEnsureDirectoryExsits(NSString *path) {
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        LHXLogError(@"error creating directory: %@", error);
    }
    
    return path;
}

#endif

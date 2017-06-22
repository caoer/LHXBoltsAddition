//
//  TMHelper.m
//  Pods
//
//  Created by Zitao Xiong on 5/12/15.
//
//

#import "LHXHelper.h"
#import "LHXLog.h"
#import "LHXAssert.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

#import <CommonCrypto/CommonCrypto.h>

#import "LHXError.h"

//GZip
#import <zlib.h>
#import <dlfcn.h>

CGFloat LHXExpectedLabelHeight(UILabel *label) {
    CGSize expectedLabelSize = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{ NSFontAttributeName : label.font }
                                                        context:nil].size;
    return expectedLabelSize.height;
}

//void TMAdjustHeightForLabel(UILabel *label) {
//    CGRect rect = label.frame;
//    rect.size.height = LHXExpectedLabelHeight(label);
//    label.frame = rect;
//}

id LHXDynamicCast_(id x, Class objClass) {
    if ([x isKindOfClass:objClass]) {
        return x;
    }
    else {
        LHXLogError(@"can't cast x:%@ into Class: %@", x, objClass);
        return nil;
    }
}

UIImage *LHXImageWithColor(UIColor *color) {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

static void LHXGetRGBAColorComponents(CGColorRef color, CGFloat *rgba)
{
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(color));
    const CGFloat *components = CGColorGetComponents(color);
    switch (model)
    {
        case kCGColorSpaceModelMonochrome:
        {
            rgba[0] = components[0];
            rgba[1] = components[0];
            rgba[2] = components[0];
            rgba[3] = components[1];
            break;
        }
        case kCGColorSpaceModelRGB:
        {
            rgba[0] = components[0];
            rgba[1] = components[1];
            rgba[2] = components[2];
            rgba[3] = components[3];
            break;
        }
        case kCGColorSpaceModelCMYK:
        case kCGColorSpaceModelDeviceN:
        case kCGColorSpaceModelIndexed:
        case kCGColorSpaceModelLab:
        case kCGColorSpaceModelPattern:
        case kCGColorSpaceModelUnknown:
        {
            
#ifdef DEBUG
            //unsupported format
            LHXLogError(@"Unsupported color model: %i", model);
#endif
            
            rgba[0] = 0.0;
            rgba[1] = 0.0;
            rgba[2] = 0.0;
            rgba[3] = 0.0;
            break;
        }
    }
}

NSString *LHXColorToHexString(CGColorRef color)
{
    CGFloat rgba[4];
    LHXGetRGBAColorComponents(color, rgba);
    uint8_t r = rgba[0]*255;
    uint8_t g = rgba[1]*255;
    uint8_t b = rgba[2]*255;
    uint8_t a = rgba[3]*255;
    if (a < 255) {
        return [NSString stringWithFormat:@"#%02x%02x%02x%02x", r, g, b, a];
    } else {
        return [NSString stringWithFormat:@"#%02x%02x%02x", r, g, b];
    }
}

UIColor *LHXRGBA(uint32_t x, CGFloat alpha) {
    CGFloat b = (x & 0xff) / 255.0f; x >>= 8;
    CGFloat g = (x & 0xff) / 255.0f; x >>= 8;
    CGFloat r = (x & 0xff) / 255.0f;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

UIColor *LHXRGB(uint32_t x) {
    return LHXRGBA(x, 1.0f);
}

void LHXRunOnMainQueueSync(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

NSString *LHXMD5Hash(NSString *string) {
    const char *str = string.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

BOOL LHXIsMainQueue() {
    static void *mainQueueKey = &mainQueueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(),
                                    mainQueueKey, mainQueueKey, NULL);
    });
    return dispatch_get_specific(mainQueueKey) == mainQueueKey;
}

void LHXExecuteOnMainQueueSynced(dispatch_block_t block) {
    LHXExecuteOnMainQueue(block, YES);
}

void LHXExecuteOnMainQueue(dispatch_block_t block, BOOL sync) {
    if (LHXIsMainQueue()) {
        block();
    }
    else {
        if (sync) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
}

NSError *LHXErrorWithMessage(NSString *message) {
    NSDictionary<NSString *, id> *errorInfo = @{NSLocalizedDescriptionKey: message};
    return [[NSError alloc] initWithDomain:LHXErrorDomain code:0 userInfo:errorInfo];
}

CGFloat LHXScreenScale() {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LHXExecuteOnMainQueueSynced(^{
            scale = [UIScreen mainScreen].scale;
        });
    });
    
    return scale;
}

CGSize LHXScreenSize() {
    // FIXME: this caches the bounds at app start, whatever those were, and then
    // doesn't update when the device is rotated. We need to find another thread-
    // safe way to get the screen size.
    
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LHXExecuteOnMainQueueSynced(^{
            size = [UIScreen mainScreen].bounds.size;
        });
    });
    
    return size;
}

CGFloat LHXRoundPixelValue(CGFloat value) {
    CGFloat scale = LHXScreenScale();
    return round(value * scale) / scale;
}

CGFloat LHXCeilPixelValue(CGFloat value) {
    CGFloat scale = LHXScreenScale();
    return ceil(value * scale) / scale;
}

CGFloat LHXFloorPixelValue(CGFloat value) {
    CGFloat scale = LHXScreenScale();
    return floor(value * scale) / scale;
}

CGSize LHXSizeInPixels(CGSize pointSize, CGFloat scale) {
    return (CGSize){
        ceil(pointSize.width * scale),
        ceil(pointSize.height * scale),
    };
}

TM_EXTERN UIViewController *LHXFindNextRespondUIViewController(UIResponder *_responder) {
    UIResponder *responder = [_responder nextResponder];
    
    while (![responder isKindOfClass:[UIViewController class]] &&
           responder != nil) {
        responder = [responder nextResponder];
    }
    
    return (UIViewController *)responder;
}

TM_EXTERN UINavigationController *LHXFindNextRespondUINavigationController(UIResponder *_responder) {
    UIResponder *responder = [_responder nextResponder];
    
    while (![responder isKindOfClass:[UINavigationController class]] &&
           responder != nil) {
        responder = [responder nextResponder];
    }
    
    return (UINavigationController *)responder;
}

BOOL LHXCheckIfObjectOverrideSelector(NSObject *object, SEL selector) {
    Class objSuperClass = [object superclass];
    BOOL isMethodOverridden = NO;
    
    while (objSuperClass != Nil) {
        isMethodOverridden = [object methodForSelector: selector] !=
        [objSuperClass instanceMethodForSelector: selector];
        
        if (isMethodOverridden) {
            break;
        }
        
        objSuperClass = [objSuperClass superclass];
    }
    
    return isMethodOverridden;
}

NSString *LHXGetDeviceName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return machine;
}

NSString *LHXGetAppVersion() {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

NSString *LHXGetAppName() {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

NSDictionary *LHXGetEnvironment() {
    NSString *platform = @"iOS";
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion] ?: @"";
    NSString *machine = LHXGetDeviceName() ? : @"";
    NSString *appVersion = LHXGetAppVersion() ? : @"";
    NSString *appName = LHXGetAppName() ? : @"";
    
    CGFloat deviceWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat deviceHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"platform":platform,
                                                                                @"osVersion":sysVersion,
                                                                                @"deviceModel":machine,
                                                                                @"appName":appName,
                                                                                @"appVersion":appVersion,
                                                                                @"deviceWidth":@(deviceWidth * scale),
                                                                                @"deviceHeight":@(deviceHeight * scale),
                                                                                @"scale":@(scale),
                                                                                }];
    return data;
}

BOOL LHXIsGzippedData(NSData *__nullable data) {
    UInt8 *bytes = (UInt8 *)data.bytes;
    return (data.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

NSData *__nullable LHXGzipData(NSData *__nullable input, float level)
{
    if (input.length == 0 || LHXIsGzippedData(input)) {
        return input;
    }
    
    void *libz = dlopen("/usr/lib/libz.dylib", RTLD_LAZY);
    int (*deflateInit2_)(z_streamp, int, int, int, int, int, const char *, int) = dlsym(libz, "deflateInit2_");
    int (*deflate)(z_streamp, int) = dlsym(libz, "deflate");
    int (*deflateEnd)(z_streamp) = dlsym(libz, "deflateEnd");
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)input.length;
    stream.next_in = (Bytef *)input.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    static const NSUInteger LHXGZipChunkSize = 16384;
    
    NSMutableData *output = nil;
    int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        output = [NSMutableData dataWithLength:LHXGZipChunkSize];
        while (stream.avail_out == 0) {
            if (stream.total_out >= output.length) {
                output.length += LHXGZipChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    
    dlclose(libz);
    
    return output;
}

NSDictionary<NSString *, id> *LHXMakeError(NSString *message,
                                           id __nullable toStringify,
                                           NSDictionary<NSString *, id> *__nullable extraData) {
    if (toStringify) {
        message = [message stringByAppendingString:[toStringify description]];
    }
    
    NSMutableDictionary<NSString *, id> *error = [extraData mutableCopy] ?: [NSMutableDictionary new];
    error[@"message"] = message;
    return error;
}

NSDictionary<NSString *, id> *LHXMakeAndLogError(NSString *message,
                                                 id __nullable toStringify,
                                                 NSDictionary<NSString *, id> *__nullable extraData) {
    NSDictionary<NSString *, id> *error = LHXMakeError(message, toStringify, extraData);
    LHXLogError(@"\nError: %@", error);
    return error;
}

NSDictionary<NSString *, id> *LHXJSErrorFromNSError(NSError *error) {
    NSString *codeWithDomain = [NSString stringWithFormat:@"E%@%zd", error.domain.uppercaseString, error.code];
    return LHXJSErrorFromCodeMessageAndNSError(codeWithDomain,
                                               error.localizedDescription,
                                               error);
}

// TODO: Remove all the error method as well as in AsyncLocalStorage
NSDictionary<NSString *, id> *LHXJSErrorFromCodeMessageAndNSError(NSString *code,
                                                                  NSString *message,
                                                                  NSError *__nullable error) {
    NSString *errorMessage;
    NSArray<NSString *> *stackTrace = [NSThread callStackSymbols];
    NSMutableDictionary *userInfo;
    NSMutableDictionary<NSString *, id> *errorInfo =
    [NSMutableDictionary dictionaryWithObject:stackTrace forKey:@"nativeStackIOS"];
    
    if (error) {
        errorMessage = error.localizedDescription ?: @"Unknown error from a native module";
        errorInfo[@"domain"] = error.domain ?: LHXErrorDomain;
        if (error.userInfo) {
            userInfo = [error.userInfo mutableCopy];
            if (userInfo != nil && userInfo[NSUnderlyingErrorKey] != nil) {
                NSError *underlyingError = error.userInfo[NSUnderlyingErrorKey];
                NSString *underlyingCode = [NSString stringWithFormat:@"%d", (int)underlyingError.code];
                userInfo[NSUnderlyingErrorKey] = LHXJSErrorFromCodeMessageAndNSError(underlyingCode, @"underlying error", underlyingError);
            }
        }
    } else {
        errorMessage = @"Unknown error from a native module";
        errorInfo[@"domain"] = LHXErrorDomain;
        userInfo = nil;
    }
    errorInfo[@"code"] = code ?: LHXErrorUnspecified;
    errorInfo[@"userInfo"] = LHXNullIfNil(userInfo);
    
    // Allow for explicit overriding of the error message
    errorMessage = message ?: errorMessage;
    
    return LHXMakeError(errorMessage, nil, errorInfo);
}

UIViewController *LHXGetTopMostPresentingViewController() {
    UIViewController *vc = [[UIApplication sharedApplication] keyWindow].rootViewController;
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

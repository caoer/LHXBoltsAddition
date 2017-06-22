//
//  TMHelper.h
//  Pods
//
//  Created by Zitao Xiong on 5/12/15.
//
//

#import <Foundation/Foundation.h>
#import "LHXMacros.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const LHXErrorDomain;


TM_EXTERN CGFloat LHXExpectedLabelHeight(UILabel *label);
TM_EXTERN void TMAdjustHeightForLabel(UILabel *label);

TM_EXTERN id __nullable LHXDynamicCast_(id x, Class objClass);
#define TMDynamicCast(x, c) ((c *) TMDynamicCast_(x, [c class]))

TM_EXTERN UIImage * __nullable LHXImageWithColor(UIColor *color);

TM_EXTERN UIColor * __nullable LHXRGB(uint32_t x);
TM_EXTERN UIColor * __nullable LHXRGBA(uint32_t x, CGFloat alpha);

LHX_INLINE CGFloat
TMCGFloatNearlyEqualToFloat(CGFloat f1, CGFloat f2) {
    const CGFloat TMCGFloatEpsilon = (CGFloat)0.01; // 0.01 should be safe enough when dealing with screen point and pixel values
    return (ABS(f1 - f2) <= TMCGFloatEpsilon);
}

TM_EXTERN void LHXRunOnMainQueueSync(void (^block)(void));
TM_EXTERN NSBundle *tm_defaultItemsBundleInFrameworkBundle(NSBundle *frameworkBundle);
TM_EXTERN NSBundle *tm_viewControllersBundleInFrameworkBundle(NSBundle *frameworkBundle);
TM_EXTERN BOOL LHXIsMainQueue();
TM_EXTERN void LHXExecuteOnMainQueueSynced(dispatch_block_t block);
TM_EXTERN void LHXExecuteOnMainQueue(dispatch_block_t block, BOOL sync);

TM_EXTERN NSString * LHXColorToHexString(CGColorRef color);
TM_EXTERN NSError *LHXErrorWithMessage(NSString *message);

// Get screen metrics in a thread-safe way
TM_EXTERN CGFloat LHXScreenScale(void);
TM_EXTERN CGSize LHXScreenSize(void);

// Round float coordinates to nearest whole screen pixel (not point)
TM_EXTERN CGFloat LHXRoundPixelValue(CGFloat value);
TM_EXTERN CGFloat LHXCeilPixelValue(CGFloat value);
TM_EXTERN CGFloat LHXFloorPixelValue(CGFloat value);

// Convert a size in points to pixels, rounded up to the nearest integral size
TM_EXTERN CGSize LHXSizeInPixels(CGSize pointSize, CGFloat scale);

TM_EXTERN UIViewController * __nullable LHXFindNextRespondUIViewController(UIResponder *responder);
TM_EXTERN UINavigationController * __nullable LHXFindNextRespondUINavigationController(UIResponder *_responder);
TM_EXTERN BOOL LHXCheckIfObjectOverrideSelector(NSObject *object, SEL selector);

TM_EXTERN NSDictionary *LHXGetEnvironment();
TM_EXTERN NSString *LHXGetAppName();
TM_EXTERN NSString *LHXGetAppVersion();
TM_EXTERN NSString *LHXGetDeviceName();
// Gzip functionality - compression level in range 0 - 1 (-1 for default)
TM_EXTERN NSData *__nullable LHXGzipData(NSData *__nullable data, float level);

TM_EXTERN NSString *LHXMD5Hash(NSString *string);

// Creates a standardized error object to return in callbacks
TM_EXTERN NSDictionary<NSString *, id> *LHXMakeError(NSString *message, id __nullable toStringify, NSDictionary<NSString *, id> *__nullable extraData);
TM_EXTERN NSDictionary<NSString *, id> *LHXMakeAndLogError(NSString *message, id __nullable toStringify, NSDictionary<NSString *, id> *__nullable extraData);
TM_EXTERN NSDictionary<NSString *, id> *LHXJSErrorFromNSError(NSError *error);
TM_EXTERN NSDictionary<NSString *, id> *LHXJSErrorFromCodeMessageAndNSError(NSString *code, NSString *message, NSError *__nullable error);


TM_EXTERN UIViewController *LHXGetTopMostPresentingViewController();

NS_ASSUME_NONNULL_END

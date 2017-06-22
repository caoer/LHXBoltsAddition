//
//  UIColor+LHXColors.h
//
//

#import <UIKit/UIKit.h>

/**
 *  The UIColor+LHXColors category extends UIColor to allow colors to be specified by SVG color name, hex strings,
 *  and hex values. Additionally, HSL color space conversions have been added
 */
@interface UIColor (LHXColors)

/**
 *  Return a UIColor from an SVG color name
 *
 *  @param name The color name
 */
+ (UIColor *)lhx_colorFromName:(NSString *)name;

/**
 *  Return a UIColor using the HSL color space
 *
 *  @param hue The color's hue
 *  @param saturation The color's saturation
 *  @param lightness The color's lightness
 */
+ (UIColor *)lhx_colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness;

/**
 *  Return a UIColor using the HSL color space and an alpha value
 *
 *  @param hue The color's hue
 *  @param saturation The color's saturation
 *  @param lightness The color's lightness
 *  @param alpha The color's alpha value
 */
+ (UIColor *)lhx_colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation lightness:(CGFloat)lightness alpha:(CGFloat)alpha;

/**
 *  Return a UIColor from a 3- or 6-digit hex string
 *
 *  @param hexString The hex color string value
 */
+ (UIColor *)lhx_colorWithHexString:(NSString *)hexString;

/**
 *  Return a UIColor from a 3- or 6-digit hex string and an alpha value
 *
 *  @param hexString The hex color string value
 *  @param alpha The color's alpha value
 */
+ (UIColor *)lhx_colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha;

/**
 *  Return a UIColor from a RGBA int
 *
 *  @param value The int value
 */
+ (UIColor *)lhx_colorWithRGBAValue:(uint)value;

/**
 *  Return a UIColor from a ARGB int
 *
 *  @param value The int value
 */
+ (UIColor *)lhx_colorWithARGBValue:(uint)value;

/**
 *  Return a UIColor from a RGB int
 *
 *  @param value The int value
 */
+ (UIColor *)lhx_colorWithRGBValue:(uint)value;

/**
 *  Convert this color to HSLA
 *
 *  @param hue A float pointer that will be set by this conversion
 *  @param saturation A float pointer that will be set by this conversion
 *  @param lightness A float pointer that will be set by this conversion
 *  @param alpha A float pointer that will be set by this conversion
 */
- (BOOL)lhx_getHue:(CGFloat *)hue saturation:(CGFloat *)saturation lightness:(CGFloat *)lightness alpha:(CGFloat *)alpha;

/**
 *  Determine if this color is opaque. Essentially, this returns true if the alpha channel is 1.0
 */
- (BOOL)lhx_isOpaque;

/**
 *  Adds percent to the lightness channel of this color
 */
- (UIColor *)lhx_darkenByPercent:(CGFloat)percent;

/**
 *  Subtracts percent from the lightness channel of this color
 */
- (UIColor *)lhx_lightenByPercent:(CGFloat)percent;

@end

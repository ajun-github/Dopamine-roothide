//
//  GlobalAppearance.h
//  Dopamine
//
//  Created by Lars Fröder on 10.10.23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define UI_IPAD_MAX_WIDTH 600
#define UI_MODAL_PADDING 30
#define UI_PADDING 26
//Action Menu
#define UI_INNER_PADDING 18
#define UI_INNER_PADDING_TINY 10
#define UI_INNER_TOP_PADDING 6
#define UI_ACTION_HEIGHT 86
#define UI_ACTION_HEIGHT_HOME_BTN 78
#define UI_ACTION_HEIGHT_TINY 64

// Shared look
#define UI_GLASS_CORNER_RADIUS 26
#define UI_GLASS_BORDER_ALPHA 0.18
#define UI_ROW_HEIGHT 58

#define SE_PHONE_SIZE_CONST 568

@interface DOGlobalAppearance : NSObject

+ (UIImageSymbolConfiguration *)smallIconImageConfiguration;
+ (UIButtonConfiguration *)defaultButtonConfiguration;
+ (UIButtonConfiguration *)defaultButtonConfigurationWithImagePadding:(CGFloat)imagePadding;
+ (NSAttributedString*)mainSubtitleString:(NSString*)string;
+ (NSAttributedString*)secondarySubtitleString:(NSString*)string;
+ (BOOL)isHomeButtonDevice;
+ (UIColor*)windowColorWithAlpha:(float)alpha;
+ (BOOL)isRTL;
+ (BOOL)isSmallDevice;

// Turns a plain view into a translucent "liquid glass" panel.
// The glass layers are inserted below all existing subviews, so it is safe to call
// on a container that already holds content. Calling it twice is a no-op.
+ (void)applyLiquidGlassToView:(UIView *)view cornerRadius:(CGFloat)cornerRadius tintColor:(nullable UIColor *)tintColor;

// A standalone glass background view (for places that need a UIView they can add themselves).
+ (UIVisualEffectView *)liquidGlassViewWithCornerRadius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END

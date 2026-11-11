//
//  GlobalAppearance.m
//  Dopamine
//
//  Created by Lars Fröder on 10.10.23.
//

#import "DOGlobalAppearance.h"
#import <CoreGraphics/CoreGraphics.h>
#import "DOThemeManager.h"

@implementation DOGlobalAppearance

+ (UIImageSymbolConfiguration *)smallIconImageConfiguration
{
    return [UIImageSymbolConfiguration configurationWithPointSize: 20 weight:UIImageSymbolWeightMedium];
}

+ (UIButtonConfiguration *)defaultButtonConfiguration
{
    UIButtonConfiguration *configuration = [UIButtonConfiguration plainButtonConfiguration];
    configuration.imagePadding = 10;
    configuration.baseForegroundColor = [UIColor whiteColor];
    configuration.titleLineBreakMode = NSLineBreakByClipping;

    // IN DARK MODE, APPLE JUST ADDS WHITE WHEN A BUTTON IS HIGHLIGHTED WHEN IT'S SET UP VIA UIButtonConfiguration
    // UNFORTUNATELY THEY FORGOT ABOUT THE POSSIBILITY ABOUT THERE BEING A WHITE BUTTON, SO THOSE JUST DON'T SHOW ANY HIGHLIGHT COLOR
    // HACKY WORKAROUND TO FIX FIX THIS MESS; SCREW APPLE
    configuration.titleTextAttributesTransformer = ^NSDictionary<NSAttributedStringKey,id> * _Nonnull(NSDictionary<NSAttributedStringKey,id> * _Nonnull textAttributes) {
        // Something makes me think the person that developed this API never actually used it...
        // OR ELSE WHERE IS MY BUTTON REFERENCE TO KNOW WHAT STATE I'M EVEN DEALING WITH???
        // THIS IS A SUPER HACKY WAY OF DETERMINING WHETHER THE BUTTON IS HIGHLIGHTED OR NOT
        // WHEN IT'S HIGHLIGHTED THE COLOR WILL BE IN UIExtendedSRGBColorSpace
        // WHEN NOT HIGHLIGHTED IT WILL BE IN UIExtendedGrayColorSpace
        // WHEN NOT IN DARK MODE IT WILL ALREADY BE WHAT WE WANT, JUST SKIP
        NSMutableDictionary<NSAttributedStringKey,id> *textAttributesM = textAttributes.mutableCopy;
        UIColor *foregroundColor = textAttributes[NSForegroundColorAttributeName];
        CGFloat alpha, white;
        [foregroundColor getWhite:&white alpha:&alpha];
        if ((int)white == 1 && (int)alpha == 1) {
            CGColorSpaceRef colorSpace = CGColorGetColorSpace(foregroundColor.CGColor);
            CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
            if (model == kCGColorSpaceModelRGB) {
                textAttributesM[NSForegroundColorAttributeName] = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
            }
        }
        // textAttributesM[NSFontAttributeName] = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        textAttributesM[NSFontAttributeName] = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
        return textAttributesM;
    };
    configuration.imageColorTransformer = ^UIColor * _Nonnull(UIColor * _Nonnull color) {
        // Something makes me think the person that developed this API never actually used it...
        // OR ELSE WHERE IS MY BUTTON REFERENCE TO KNOW WHAT STATE I'M EVEN DEALING WITH???
        // THIS IS A SUPER HACKY WAY OF DETERMINING WHETHER THE BUTTON IS HIGHLIGHTED OR NOT
        // WHEN IT'S HIGHLIGHTED THE COLOR WILL BE IN UIExtendedSRGBColorSpace
        // WHEN NOT HIGHLIGHTED IT WILL BE IN UIExtendedGrayColorSpace
        // WHEN NOT IN DARK MODE IT WILL ALREADY BE WHAT WE WANT, JUST SKIP
        CGFloat alpha, white;
        [color getWhite:&white alpha:&alpha];
        if ((int)white == 1 && (int)alpha == 1) {
            CGColorSpaceRef colorSpace = CGColorGetColorSpace(color.CGColor);
            CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
            if (model == kCGColorSpaceModelRGB) {
                return [color colorWithAlphaComponent:0.75];
            }
        }
        return color;
    };
    
    return configuration;
}

+ (UIButtonConfiguration *)defaultButtonConfigurationWithImagePadding:(CGFloat)imagePadding
{
    UIButtonConfiguration *configuration = [DOGlobalAppearance defaultButtonConfiguration];
    configuration.imagePadding = imagePadding;
    return configuration;
}

#pragma mark - Attributed Strings

+ (NSAttributedString*)mainSubtitleString:(NSString*)string
{
    return [[NSAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightMedium],
        NSForegroundColorAttributeName: [UIColor whiteColor],
    }];
}

+ (NSAttributedString*)secondarySubtitleString:(NSString*)string
{
    return [[NSAttributedString alloc] initWithString:string attributes:@{
        NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightRegular],
        NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.60],
    }];
}

+ (BOOL)isHomeButtonDevice
{
   return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom == 0;
}

+ (BOOL)isRTL
{
    return [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

+ (BOOL)isSmallDevice
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    return window.frame.size.height < SE_PHONE_SIZE_CONST + 50;
}

#pragma mark - Liquid Glass

static NSInteger const kDOGlassTag = 9417;
static NSInteger const kDOGlassTintTag = 9418;
static NSInteger const kDOGlassSheenTag = 9419;

+ (NSArray<NSLayoutConstraint *> *)edgeConstraintsForView:(UIView *)child inView:(UIView *)parent
{
    return @[
        [child.leadingAnchor constraintEqualToAnchor:parent.leadingAnchor],
        [child.trailingAnchor constraintEqualToAnchor:parent.trailingAnchor],
        [child.topAnchor constraintEqualToAnchor:parent.topAnchor],
        [child.bottomAnchor constraintEqualToAnchor:parent.bottomAnchor],
    ];
}

// A white-to-clear vertical gradient, stretched across the top half of a panel.
// It is what makes the surface read as glass instead of plain blur.
+ (UIImage *)glassSheenImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(2, 64);
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size];
        image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
            CGContextRef ctx = context.CGContext;
            CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
            CGFloat components[8] = {
                1.0, 1.0, 1.0, 0.16,
                1.0, 1.0, 1.0, 0.0,
            };
            CGFloat locations[2] = { 0.0, 1.0 };
            CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, 2);
            CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, size.height), 0);
            CGGradientRelease(gradient);
            CGColorSpaceRelease(space);
        }];
    });
    return image;
}

+ (UIVisualEffectView *)liquidGlassViewWithCornerRadius:(CGFloat)cornerRadius
{
    UIVisualEffectView *glass = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark]];
    glass.translatesAutoresizingMaskIntoConstraints = NO;
    glass.userInteractionEnabled = NO;
    glass.layer.cornerRadius = cornerRadius;
    glass.layer.cornerCurve = kCACornerCurveContinuous;
    glass.layer.masksToBounds = YES;
    return glass;
}

+ (void)applyLiquidGlassToView:(UIView *)view cornerRadius:(CGFloat)cornerRadius tintColor:(UIColor *)tintColor
{
    if (!view || [view viewWithTag:kDOGlassTag]) {
        return;
    }

    view.backgroundColor = [UIColor clearColor];
    view.layer.cornerRadius = cornerRadius;
    view.layer.cornerCurve = kCACornerCurveContinuous;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 1.0;
    view.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:UI_GLASS_BORDER_ALPHA].CGColor;

    UIVisualEffectView *glass = [self liquidGlassViewWithCornerRadius:cornerRadius];
    glass.tag = kDOGlassTag;
    [view insertSubview:glass atIndex:0];
    [NSLayoutConstraint activateConstraints:[self edgeConstraintsForView:glass inView:view]];

    UIView *topmost = glass;
    if (tintColor) {
        UIView *tint = [[UIView alloc] init];
        tint.tag = kDOGlassTintTag;
        tint.translatesAutoresizingMaskIntoConstraints = NO;
        tint.userInteractionEnabled = NO;
        tint.backgroundColor = [tintColor colorWithAlphaComponent:0.32];
        [view insertSubview:tint aboveSubview:glass];
        [NSLayoutConstraint activateConstraints:[self edgeConstraintsForView:tint inView:view]];
        topmost = tint;
    }

    UIImageView *sheen = [[UIImageView alloc] initWithImage:[self glassSheenImage]];
    sheen.tag = kDOGlassSheenTag;
    sheen.contentMode = UIViewContentModeScaleToFill;
    sheen.userInteractionEnabled = NO;
    sheen.alpha = 0.9;
    sheen.translatesAutoresizingMaskIntoConstraints = NO;
    [view insertSubview:sheen aboveSubview:topmost];
    [NSLayoutConstraint activateConstraints:@[
        [sheen.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [sheen.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [sheen.topAnchor constraintEqualToAnchor:view.topAnchor],
        [sheen.heightAnchor constraintEqualToAnchor:view.heightAnchor multiplier:0.5],
    ]];
}

@end

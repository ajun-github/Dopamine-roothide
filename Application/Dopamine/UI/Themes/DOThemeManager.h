//
//  DOThemeManager.h
//  Dopamine
//
//  Created by tomt000 on 14/02/2024.
//

#import <Foundation/Foundation.h>
#import "DOTheme.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const DOThemeBackgroundDidChangeNotification;

@interface DOThemeManager : NSObject

@property (nonatomic, retain) NSArray<DOTheme*> *themes;

+ (instancetype)sharedInstance;

+ (UIColor*)menuColorWithAlpha:(float)alpha;
- (NSArray*)getAvailableThemeKeys;
- (NSArray*)getAvailableThemeNames;
- (DOTheme*)getThemeForKey:(NSString*)key;
- (DOTheme*)enabledTheme;

// Custom background image
- (BOOL)isCustomBackgroundEnabled;
- (void)setCustomBackgroundEnabled:(BOOL)enabled;
- (BOOL)hasCustomBackgroundImage;
- (nullable UIImage *)customBackgroundImage;
- (void)saveCustomBackgroundImage:(UIImage *)image;
- (void)removeCustomBackgroundImage;

// Background opacity (0.0 - 1.0), applies to both custom and theme backgrounds
- (float)backgroundOpacity;
- (void)setBackgroundOpacity:(float)opacity;

// The image that should currently be displayed as the app background
- (UIImage *)currentBackgroundImage;

// Posts DOThemeBackgroundDidChangeNotification so the UI can update immediately
- (void)notifyBackgroundChanged;

@end

NS_ASSUME_NONNULL_END

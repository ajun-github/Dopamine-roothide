//
//  DOThemeManager.m
//  Dopamine
//
//  Created by tomt000 on 14/02/2024.
//

#import "DOThemeManager.h"
#import "DOPreferenceManager.h"
#import <math.h>

NSNotificationName const DOThemeBackgroundDidChangeNotification = @"DOThemeBackgroundDidChangeNotification";

static NSString *const kDOCustomBackgroundEnabledKey = @"customBackgroundEnabled";
static NSString *const kDOBackgroundOpacityKey = @"backgroundOpacity";
static NSString *const kDOCustomBackgroundFileName = @"customBackground.jpg";
static const CGFloat kDOMaxCustomBackgroundDimension = 2732.0;

@interface DOThemeManager ()
@property (nonatomic, strong, nullable) UIImage *cachedCustomBackgroundImage;
@end

@implementation DOThemeManager

+ (instancetype)sharedInstance
{
    static DOThemeManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DOThemeManager alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.themes = [[NSMutableArray alloc] init];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Themes" ofType:@"plist"];
        NSArray *themes = [NSArray arrayWithContentsOfFile:path];

        for (NSDictionary *theme in themes) {
            DOTheme *newTheme = [[DOTheme alloc] initWithDictionary:theme];
            [((NSMutableArray *)self.themes) addObject:newTheme];
        }

    }
    return self;
}

- (NSArray*)getAvailableThemeKeys
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (DOTheme *theme in _themes) {
        [keys addObject:theme.key];
    }
    return keys;
}

- (NSArray*)getAvailableThemeNames
{
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (DOTheme *theme in _themes) {
        [names addObject:theme.name];
    }
    return names;
}

- (DOTheme*)getThemeForKey:(NSString*)key
{
    for (DOTheme *theme in _themes) {
        if ([theme.key isEqualToString:key]) {
            return theme;
        }
    }
    return nil;
}

- (DOTheme*)enabledTheme
{
    id value = [[DOPreferenceManager sharedManager] preferenceValueForKey:@"theme"];
    if (!value)
        return self.themes.firstObject;
    return [self getThemeForKey:value] ?: self.themes.firstObject;
}


+ (UIColor*)menuColorWithAlpha:(float)alpha
{
    DOTheme *theme = [[DOThemeManager sharedInstance] enabledTheme];
    
    UIColor *color = theme.actionMenuColor;
    CGFloat red, green, blue, currentAlpha;
    [color getRed:&red green:&green blue:&blue alpha:&currentAlpha];
    return [UIColor colorWithRed:red green:green blue:blue alpha:currentAlpha * alpha];
}

#pragma mark - Custom Background

- (NSString *)customBackgroundPath
{
    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", kDOCustomBackgroundFileName]];
}

- (BOOL)isCustomBackgroundEnabled
{
    return [[DOPreferenceManager sharedManager] boolPreferenceValueForKey:kDOCustomBackgroundEnabledKey fallback:NO];
}

- (void)setCustomBackgroundEnabled:(BOOL)enabled
{
    [[DOPreferenceManager sharedManager] setPreferenceValue:@(enabled) forKey:kDOCustomBackgroundEnabledKey];
    [self notifyBackgroundChanged];
}

- (BOOL)hasCustomBackgroundImage
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self customBackgroundPath]];
}

- (UIImage *)customBackgroundImage
{
    if (self.cachedCustomBackgroundImage) {
        return self.cachedCustomBackgroundImage;
    }
    if (![self hasCustomBackgroundImage]) {
        return nil;
    }
    UIImage *image = [UIImage imageWithContentsOfFile:[self customBackgroundPath]];
    self.cachedCustomBackgroundImage = image;
    return image;
}

// Redraws the image at a reasonable resolution, which also normalizes its orientation.
- (UIImage *)preparedBackgroundImage:(UIImage *)image
{
    CGSize size = image.size;
    if (size.width <= 0 || size.height <= 0) {
        return image;
    }

    CGFloat scale = MIN(1.0, kDOMaxCustomBackgroundDimension / MAX(size.width, size.height));
    CGSize targetSize = CGSizeMake(round(size.width * scale), round(size.height * scale));

    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result ?: image;
}

- (void)saveCustomBackgroundImage:(UIImage *)image
{
    if (!image) {
        return;
    }

    UIImage *preparedImage = [self preparedBackgroundImage:image];
    NSData *data = UIImageJPEGRepresentation(preparedImage, 0.9);
    if (!data) {
        return;
    }

    [data writeToFile:[self customBackgroundPath] atomically:YES];
    self.cachedCustomBackgroundImage = preparedImage;
    [self notifyBackgroundChanged];
}

- (void)removeCustomBackgroundImage
{
    [[NSFileManager defaultManager] removeItemAtPath:[self customBackgroundPath] error:nil];
    self.cachedCustomBackgroundImage = nil;
    [self notifyBackgroundChanged];
}

#pragma mark - Background Opacity

- (float)backgroundOpacity
{
    id value = [[DOPreferenceManager sharedManager] preferenceValueForKey:kDOBackgroundOpacityKey];
    float opacity = value ? [value floatValue] : 1.0;
    return MAX(0.0, MIN(1.0, opacity));
}

- (void)setBackgroundOpacity:(float)opacity
{
    opacity = MAX(0.0, MIN(1.0, opacity));
    [[DOPreferenceManager sharedManager] setPreferenceValue:@(opacity) forKey:kDOBackgroundOpacityKey];
    [self notifyBackgroundChanged];
}

#pragma mark - Current Background

- (UIImage *)currentBackgroundImage
{
    if ([self isCustomBackgroundEnabled]) {
        UIImage *customImage = [self customBackgroundImage];
        if (customImage) {
            return customImage;
        }
    }
    return [self enabledTheme].image;
}

- (void)notifyBackgroundChanged
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DOThemeBackgroundDidChangeNotification object:self];
}

@end

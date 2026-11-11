//
//  DOBackgroundOpacityCell.m
//  Dopamine
//

#import "DOBackgroundOpacityCell.h"
#import "DOThemeManager.h"
#import <math.h>

@interface DOBackgroundOpacityCell ()

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation DOBackgroundOpacityCell

- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(PSSpecifier *)specifier
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = [specifier propertyForKey:@"title"] ?: [specifier name];
        titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:titleLabel];

        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightMedium];
        self.valueLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        self.valueLabel.textAlignment = NSTextAlignmentRight;
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.valueLabel];

        self.slider = [[UISlider alloc] init];
        self.slider.minimumValue = 0.1;
        self.slider.maximumValue = 1.0;
        self.slider.continuous = YES;
        self.slider.minimumTrackTintColor = [UIColor colorWithRed:71.0/255.0 green:169.0/255.0 blue:135.0/255.0 alpha:1.0];
        self.slider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.2];
        self.slider.translatesAutoresizingMaskIntoConstraints = NO;
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.slider];

        [NSLayoutConstraint activateConstraints:@[
            [titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
            [titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:16],
            [self.valueLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
            [self.valueLabel.centerYAnchor constraintEqualToAnchor:titleLabel.centerYAnchor],
            [self.valueLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:titleLabel.trailingAnchor constant:8],
            [self.slider.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
            [self.slider.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
            [self.slider.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:10],
            [self.slider.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12],
        ]];

        self.slider.value = [[DOThemeManager sharedInstance] backgroundOpacity];
        [self updateValueLabel];
    }
    return self;
}

- (void)sliderValueChanged:(UISlider *)slider
{
    [[DOThemeManager sharedInstance] setBackgroundOpacity:slider.value];
    [self updateValueLabel];
}

- (void)updateValueLabel
{
    self.valueLabel.text = [NSString stringWithFormat:@"%d%%", (int)round(self.slider.value * 100.0)];
}

@end

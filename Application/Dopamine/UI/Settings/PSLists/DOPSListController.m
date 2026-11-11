//
//  DOPSListController.m
//  Dopamine
//
//  Created by tomt000 on 26/01/2024.
//

#import "DOPSListController.h"
#import "DOThemeManager.h"
#import "DOGlobalAppearance.h"
#import "DOButtonCell.h"
#import "DOHeaderCell.h"
#import "DOBackgroundOpacityCell.h"
#import <Preferences/PSTableCell.h>

@interface DOPSListController ()

@end

@implementation DOPSListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_table setSeparatorColor:[UIColor clearColor]];
    [_table setBackgroundColor:[UIColor clearColor]];
    [DOPSListController setupViewControllerStyle:self];
}

+ (void)setupViewControllerStyle:(UIViewController*)vc
{
    DOTheme *theme = [[DOThemeManager sharedInstance] enabledTheme];

    vc.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    [DOGlobalAppearance applyLiquidGlassToView:vc.view
                                  cornerRadius:UI_GLASS_CORNER_RADIUS
                                     tintColor:theme.windowColor];

    if (@available(iOS 19.0, *)) {
        // Apple broke the method below by reimplementing some Preferences.framework classes in SwiftUI 🤮
        // Now onTintColor is only implemented when the cell is initialized but gets reset to the stock color when the cell is reused
        // I tried hard to fix it but failed in the end, so we will need to just use the stock tint color on iOS 26.0+
    }
    else {
        [UISwitch appearanceWhenContainedInInstancesOfClasses:@[[vc class]]].onTintColor = [UIColor colorWithRed: 71.0/255.0 green: 169.0/255.0 blue: 135.0/255.0 alpha: 1.0];
    }
}

// A bigger, easier to read list: the Preferences cells keep their stock fonts,
// so they are scaled up here once they are about to be displayed.
+ (void)enlargeLabelsInCell:(UITableViewCell *)cell
{
    if ([cell isKindOfClass:[DOButtonCell class]] ||
        [cell isKindOfClass:[DOHeaderCell class]] ||
        [cell isKindOfClass:[DOBackgroundOpacityCell class]]) {
        return;
    }

    if ([cell isKindOfClass:[PSTableCell class]] && [cell respondsToSelector:@selector(titleLabel)]) {
        id titleLabel = [(PSTableCell *)cell titleLabel];
        if ([titleLabel isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)titleLabel;
            label.font = [UIFont systemFontOfSize:19 weight:UIFontWeightMedium];
        }
    }

    for (UIView *subview in cell.contentView.subviews) {
        if (![subview isKindOfClass:[UILabel class]]) {
            continue;
        }
        UILabel *label = (UILabel *)subview;
        if (label.font.pointSize < 17.0) {
            label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    [DOPSListController enlargeLabelsInCell:cell];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _table.frame = CGRectMake(14, 8, self.view.bounds.size.width - 28, self.view.bounds.size.height - 16);
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end

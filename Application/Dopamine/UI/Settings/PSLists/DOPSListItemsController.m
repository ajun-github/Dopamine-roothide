//
//  DOPSListItemsController.m
//  Dopamine
//
//  Created by tomt000 on 26/01/2024.
//

#import "DOPSListItemsController.h"
#import "DOPSListController.h"

@interface DOPSListItemsController ()

@end

@implementation DOPSListItemsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_table setSeparatorColor:[UIColor clearColor]];
    [_table setBackgroundColor:[UIColor clearColor]];
    [DOPSListController setupViewControllerStyle: self];
    
    _table.tableHeaderView = [DOPSListItemsController makeHeader: ((PSSpecifier*)self.specifier).name withTarget:self];
}

+ (UIView *)makeHeader:(NSString *)title withTarget:(id)target
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 84)];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 74)];
    label.text = title;
    label.font = [UIFont systemFontOfSize:21 weight:UIFontWeightSemibold];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:label];

    UIView *border = [[UIView alloc] init];
    border.translatesAutoresizingMaskIntoConstraints = NO;
    border.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    [header addSubview:border];

    UIImage *backImage = [UIImage systemImageNamed:@"chevron.left" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIImageSymbolWeightMedium]];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton setTintColor:[UIColor colorWithWhite:1.0 alpha:0.6]];
    [backButton addTarget:target action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:backButton];

    [NSLayoutConstraint activateConstraints:@[
        [label.centerYAnchor constraintEqualToAnchor:header.centerYAnchor constant:-8],
        [label.centerXAnchor constraintEqualToAnchor:header.centerXAnchor]
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [border.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:20],
        [border.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-20],
        [border.bottomAnchor constraintEqualToAnchor:header.bottomAnchor constant:-12],
        [border.heightAnchor constraintEqualToConstant:1]
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [backButton.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:8],
        [backButton.centerYAnchor constraintEqualToAnchor:header.centerYAnchor constant:-6],
        [backButton.widthAnchor constraintEqualToConstant:44],
        [backButton.heightAnchor constraintEqualToConstant:44]
    ]];

    return header;
}

- (void)dismiss {
    [self.navigationController popViewControllerAnimated:YES];
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

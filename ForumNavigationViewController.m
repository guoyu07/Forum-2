//
//  ForumNavigationViewController.m
//  Forum
//
//  Created by WDY on 2016/11/22.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumNavigationViewController.h"
#import "ForumBrowserDelegate.h"
#import "ForumApiHelper.h"

@interface ForumNavigationViewController ()

@end

@implementation ForumNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig];
    self.navigationBar.barTintColor = forumConfig.themeColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

@end

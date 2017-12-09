//
//  ForumTabBarController.m
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumTabBarController.h"
#import "DrawerView.h"
#import "AppDelegate.h"
#import "LocalForumApi.h"

@interface ForumTabBarController () {
    DrawerView *_leftDrawerView;
}

@end

@implementation ForumTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (![self isNeedHideLeftMenu]){
        _leftDrawerView = [[DrawerView alloc] initWithDrawerType:DrawerViewTypeLeft andXib:@"DrawerView"];
        [self.view addSubview:_leftDrawerView];
    }

}

- (BOOL)isNeedHideLeftMenu {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forum"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLeftDrawer{
    [_leftDrawerView openLeftDrawer];
}

- (void)bringLeftDrawerToFront {
    if (![self isNeedHideLeftMenu]){
        [_leftDrawerView bringDrawerToFront];
    }
}
@end

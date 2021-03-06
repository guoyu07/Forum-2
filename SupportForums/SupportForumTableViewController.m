//
//  ForumTableViewController.m
//  DRL
//
//  Created by 迪远 王 on 16/5/21.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "SupportForumTableViewController.h"
#import "ForumThreadListTableViewController.h"
#import "ForumTabBarController.h"
#import "UIStoryboard+Forum.h"
#import "SupportForums.h"
#import "AppDelegate.h"
#import "LocalForumApi.h"
#import "PayManager.h"
#import "ForumSupportNavigationController.h"

@interface SupportForumTableViewController ()<CAAnimationDelegate>{
    LocalForumApi *localForumApi;
}

@end

@implementation SupportForumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    localForumApi = [[LocalForumApi alloc] init];
    self.forumApi = [ForumApiHelper forumApi:localForumApi.currentForumHost];


    [self.dataList removeAllObjects];

    [self.dataList addObjectsFromArray:localForumApi.supportForums];

    [self.tableView reloadData];


    if ([localForumApi isHaveLoginForum]) {
        if (self.canBack) {
            self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_arrow_back_18pt"];
        } else {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            UIViewController *rootViewController = window.rootViewController;
            if ([rootViewController isKindOfClass:[ForumSupportNavigationController class]]){
                self.navigationItem.leftBarButtonItem.image = nil;
                self.navigationItem.leftBarButtonItem.title = @"";
            } else {
                self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_close_18pt"];
            }

        }
    } else {
        self.navigationItem.leftBarButtonItem.image = nil;
        self.navigationItem.leftBarButtonItem.title = @"";
    }

}

- (BOOL) canBack{
    return self.presentingViewController != nil;
}

- (BOOL)setPullRefresh:(BOOL)enable {
    return NO;
}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (BOOL)autoPullfresh {
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"SupportForum"];


    Forums *forums = self.dataList[(NSUInteger) indexPath.row];

    cell.textLabel.text = forums.name;

    NSString * login = [localForumApi isHaveLogin:forums.host] ? @"已登录" : @"未登录";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t~\t%@", forums.host.uppercaseString, login];
    forums.host;

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0,16,0,16);
    [cell setSeparatorInset:edgeInsets];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowThreadList"]) {
        ForumThreadListTableViewController *controller = segue.destinationViewController;

        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        Forum *select = self.dataList[(NSUInteger) path.section];
        Forum *child = select.childForums[(NSUInteger) path.row];

        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:child forKey:@"TransForm"];
        [self transBundle:bundle forController:controller];

    }
}

- (BOOL)isUserHasLogin:(NSString*)host {
    // 判断是否登录
    return [[[LocalForumApi alloc] init] isHaveLogin:host];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    

    if (YES) {
        Forums *forums = self.dataList[(NSUInteger) indexPath.row];

        NSURL * url = [NSURL URLWithString:forums.url];

        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        [localForumApi saveCurrentForumURL:forums.url];

        if ([self isUserHasLogin:url.host]) {

            UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
            [stortboard changeRootViewControllerTo:@"ForumTabBarControllerId"];

        } else{

            id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig:localForumApi.currentForumHost];

            NSString * cId = forumConfig.loginControllerId;
            [[UIStoryboard mainStoryboard] changeRootViewControllerTo:cId withAnim:UIViewAnimationOptionTransitionFlipFromTop];
        }
    } else {
//        PayManager *payManager = [PayManager shareInstance];
//        [payManager payForProductID:@"CCF"];
    }


}


- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

- (IBAction)cancel:(id)sender {

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];

    if (![localForumApi isHaveLogin:localForumApi.currentForumHost]){
        NSArray<Forums *> * loginForums = localForumApi.loginedSupportForums;
        if(loginForums != nil && loginForums.count >0){
            [localForumApi saveCurrentForumURL:loginForums.firstObject.url];
        }
    }

    if ([localForumApi isHaveLoginForum]){
        if (self.canBack){
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil  ];
        }
    } else {
        //[self exitApplication];
    }
}

- (void)exitApplication {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.delegate = self;

    rotationAnimation.fillMode=kCAFillModeForwards;
    
    rotationAnimation.removedOnCompletion = NO;
    //旋转角度
    rotationAnimation.toValue = @((float) (M_PI / 2));
    //每次旋转的时间（单位秒）
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
    rotationAnimation.repeatCount = 0;
    [window.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    exit(0);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end




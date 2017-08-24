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
#import "NSUserDefaults+Extensions.h"
#import "UIStoryboard+Forum.h"
#import "SupportForums.h"
#import "Forums.h"
#import "ForumLoginViewController.h"
#import "AppDelegate.h"
#import "ForumNavigationViewController.h"
#import "BaseForumApi.h"
#import "LocalForumApi.h"


@interface SupportForumTableViewController ()<CAAnimationDelegate>

@end

@implementation SupportForumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.forumApi = [ForumApiHelper forumApi];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"supportForums" ofType:@"json"]];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];

    SupportForums *supportForums = [SupportForums modelObjectWithDictionary:dictionary];


    [self.dataList removeAllObjects];

    [self.dataList addObjectsFromArray:supportForums.forums];

    [self.tableView reloadData];

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
    Forums *forums = self.dataList[(NSUInteger) indexPath.row];
    
    NSURL * url = [NSURL URLWithString:forums.url];
    
    [[NSUserDefaults standardUserDefaults] saveCurrentForumURL:forums.url];
    
    if ([self isUserHasLogin:url.host]) {
        UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
        [stortboard changeRootViewControllerTo:@"ForumTabBarControllerId"];
        
    } else{

        id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig];
        
        NSString * cId = forumConfig.loginControllerId;
        [[UIStoryboard mainStoryboard] changeRootViewControllerTo:cId withAnim:UIViewAnimationOptionTransitionFlipFromTop];
    }

}


- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

- (IBAction)cancel:(id)sender {
    
    [self exitApplication];

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




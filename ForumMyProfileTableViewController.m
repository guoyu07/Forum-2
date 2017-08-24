//
//  ForumMyProfileTableViewController.m
//
//  Created by 迪远 王 on 16/10/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumMyProfileTableViewController.h"
#import <UIImageView+WebCache.h>
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "UIStoryboard+Forum.h"
#import "AppDelegate.h"
#import "ForumTabBarController.h"
#import "BaseForumApi.h"
#import "LocalForumApi.h"


@interface ForumMyProfileTableViewController () {
    UserProfile *userProfile;

    UIImage *defaultAvatarImage;

    ForumCoreDataManager *coreDateManager;

    NSMutableDictionary *avatarCache;

    NSMutableArray<UserEntry *> *cacheUsers;
}

@end

@implementation ForumMyProfileTableViewController

- (instancetype)init {
    if (self = [super init]) {
        [self initProfileData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initProfileData];
    }
    return self;
}

- (void)initProfileData {
    
    defaultAvatarImage = [UIImage imageNamed:@"defaultAvatar.gif"];

    avatarCache = [NSMutableDictionary dictionary];


    coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    if (cacheUsers == nil) {
        LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
        cacheUsers = [[coreDateManager selectData:^NSPredicate * {
            return [NSPredicate predicateWithFormat:@"forumHost = %@ AND userID > %d", localForumApi.currentForumHost, 0];
        }] copy];
    }

    for (UserEntry *user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    if ([self isNeedHideLeftMenu]){
        self.navigationItem.leftBarButtonItem = nil;
    }

    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0,16,0,16);
    [self.tableView setSeparatorInset:edgeInsets];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
}

- (BOOL)isNeedHideLeftMenu {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];
    return ![bundleId isEqualToString:@"com.andforce.forum"];

}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}


- (void)onPullRefresh {

    id<ForumConfigDelegate> config = [ForumApiHelper forumConfig];
    NSString *currentUserId = [[[LocalForumApi alloc] init] getLoginUser:config.forumURL.host].userID;

    [self.forumApi showProfileWithUserId:currentUserId handler:^(BOOL isSuccess, UserProfile *message) {
        userProfile = message;

        [self.tableView.mj_header endRefreshing];

        [self showAvatar:_prifileAvatar userId:userProfile.profileUserId];
        _profileName.text = userProfile.profileName;
        _profileRank.text = userProfile.profileRank;

        _registerDate.text = userProfile.profileRegisterDate;
        _lastLoginTime.text = userProfile.profileRecentLoginDate;
        _postCount.text = userProfile.profileTotalPostCount;
    }];
}

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)userId {

    // 不知道什么原因，userID可能是nil
    if (userId == nil) {
        [avatarImageView setImage:defaultAvatarImage];
        return;
    }
    NSString *avatarInArray = [avatarCache valueForKey:userId];

    if (avatarInArray == nil) {

        [self.forumApi getAvatarWithUserId:userId handler:^(BOOL isSuccess, NSString *avatar) {

            if (isSuccess) {
                LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];
                // 存入数据库
                [coreDateManager insertOneData:^(id src) {
                    UserEntry *user = (UserEntry *) src;
                    user.userID = userId;
                    user.userAvatar = avatar;
                    user.forumHost = localeForumApi.currentForumHost;
                }];
                // 添加到Cache中
                [avatarCache setValue:avatar forKey:userId];

                // 显示头像
                if (avatar == nil) {
                    [avatarImageView setImage:defaultAvatarImage];
                } else {
                    NSURL *avatarUrl = [NSURL URLWithString:avatar];
                    [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatarImage];
                }
            } else {
                [avatarImageView setImage:defaultAvatarImage];
            }

        }];
    } else {

        id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig];

        if ([avatarInArray isEqualToString:forumConfig.avatarNo]) {
            [avatarImageView setImage:defaultAvatarImage];
        } else {

            NSURL *avatarUrl = [NSURL URLWithString:avatarInArray];

            if (/* DISABLES CODE */ (NO)) {
                NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:avatarUrl];
                NSString *cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
                NSLog(@"cache_image_path %@", cacheImagePath);
            }

            [avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:defaultAvatarImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error) {
                    [coreDateManager deleteData:^NSPredicate *{
                        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND userID = %@", self.currentForumHost, userId];
                    }];
                }
                //NSError * e = error;
            }];
        }
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 3 && indexPath.row == 1) {

        LocalForumApi *forumApi = [[LocalForumApi alloc] init];
        [forumApi logout];


        id<ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig];
        NSString * id = forumConfig.loginControllerId;
        [[UIStoryboard mainStoryboard] changeRootViewControllerTo:id];

    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}

- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;
    
    [controller showLeftDrawer];
}

@end

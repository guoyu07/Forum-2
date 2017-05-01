//
//  ForumUserThreadTableViewController.m
//
//  Created by 迪远 王 on 16/3/29.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumUserThreadTableViewController.h"
#import "ForumSearchResultCell.h"
#import "ForumWebViewController.h"
#import "TransBundleDelegate.h"

@interface ForumUserThreadTableViewController () <TransBundleDelegate> {
    UserProfile *userProfile;
}

@end

@implementation ForumUserThreadTableViewController

- (void)transBundle:(TransBundle *)bundle {
    userProfile = [bundle getObjectValue:@"UserProfile"];
}


- (void)onPullRefresh {
    int userId = [userProfile.profileUserId intValue];
    [self.forumApi listAllUserThreads:userId withPage:1 handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            [self.tableView.mj_footer endRefreshing];

            self.currentPage = 1;
            [self.dataList removeAllObjects];

            [self.dataList addObjectsFromArray:message.threadList];
            [self.tableView reloadData];

        }
    }];
}

- (void)onLoadMore {
    int userId = [userProfile.profileUserId intValue];
    [self.forumApi listAllUserThreads:userId withPage:self.currentPage + 1 handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            self.currentPage++;
            if (self.currentPage >= message.totalPageCount) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataList addObjectsFromArray:message.threadList];
            [self.tableView reloadData];

        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SearchResultCell";
    ForumSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];
    [cell setData:thread];

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];


        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [bundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];
        [self transBundle:bundle forController:controller];
    }
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

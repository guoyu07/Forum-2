//
//  ForumShowNewThreadPostTableViewController.m
//
//  Created by 迪远 王 on 16/3/6.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumShowNewThreadPostTableViewController.h"

#import "ForumSearchResultCell.h"
#import "ForumUserProfileTableViewController.h"
#import "ForumTabBarController.h"
#import "ForumWebViewController.h"

@interface ForumShowNewThreadPostTableViewController () <ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    UIStoryboardSegue *selectSegue;
}

@end

@implementation ForumShowNewThreadPostTableViewController

- (void)onPullRefresh {
    [self.forumApi listNewThreadPostsWithPage:1 handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_header endRefreshing];
        if (isSuccess) {
            [self.tableView.mj_footer endRefreshing];

            self.currentPage = 1;
            self.totalPage = (int) message.totalPageCount;

            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:message.threadList];
            [self.tableView reloadData];
        }

    }];
}

- (void)onLoadMore {
    [self.forumApi listNewThreadPostsWithPage:self.currentPage + 1 handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_footer endRefreshing];
        if (isSuccess) {
            self.currentPage++;
            self.totalPage = (int) message.totalPageCount;
            if (self.currentPage >= self.totalPage) {
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
    cell.showUserProfileDelegate = self;

    ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];
    [cell setData:thread forIndexPath:indexPath];

    cell.showUserProfileDelegate = self;

    cell.indexPath = indexPath;

    cell.delegate = self;

    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"收藏此主题" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    [cell setData:self.dataList[(NSUInteger) indexPath.row] forIndexPath:indexPath];
    return cell;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self isNeedHideLeftMenu]){
        self.navigationItem.leftBarButtonItem = nil;
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];

}

- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;


    NormalThread *play = self.dataList[(NSUInteger) indexPath.row];

    [self.forumApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {

    }];


    return YES;
}

- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    TransBundle * bundle = [[TransBundle alloc] init];
    ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];
        TransBundle *transBundle = [[TransBundle alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (IBAction)showLeftDrawer:(id)sender {

    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;
    
    [controller showLeftDrawer];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
@end

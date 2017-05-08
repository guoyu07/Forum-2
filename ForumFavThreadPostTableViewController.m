//
//  ForumFavThreadPostTableViewController.m
//
//  Created by 迪远 王 on 16/3/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumFavThreadPostTableViewController.h"
#import "ForumSimpleThreadTableViewCell.h"
#import "ForumTabBarController.h"
#import "ForumWebViewController.h"
#import "ForumUserProfileTableViewController.h"

@interface ForumFavThreadPostTableViewController () <MGSwipeTableCellDelegate, ThreadListCellDelegate> {
    UIStoryboardSegue *selectSegue;
}

@end

@implementation ForumFavThreadPostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;
}

- (void)onPullRefresh {
    [self.forumApi listFavoriteThreadPostsWithPage:1 handler:^(BOOL isSuccess, ViewForumPage *resultPage) {

        [self.tableView.mj_header endRefreshing];
        if (isSuccess) {

            [self.tableView.mj_header endRefreshing];

            self.currentPage = 1;
            self.totalPage = (int) resultPage.totalPageCount;
            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:resultPage.threadList];
            [self.tableView reloadData];
        }
    }];
}

- (void)onLoadMore {
    [self.forumApi listFavoriteThreadPostsWithPage:self.currentPage handler:^(BOOL isSuccess, ViewForumPage *resultPage) {

        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            self.totalPage = (int) resultPage.totalPageCount;
            self.currentPage++;
            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataList addObjectsFromArray:resultPage.threadList];

            [self.tableView reloadData];
        }
    }];
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"SimpleThreadTableViewCell";
    ForumSimpleThreadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.showUserProfileDelegate = self;
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"取消收藏" backgroundColor:[UIColor lightGrayColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;

    Thread *list = self.dataList[(NSUInteger) indexPath.row];
    [cell setData:list forIndexPath:indexPath];

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}


- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {

    Thread *list = self.dataList[(NSUInteger) cell.indexPath.row];

    [self.forumApi unfavoriteThreadPostWithId:list.threadID handler:^(BOOL isSuccess, id message) {
        NSLog(@">>>>>>>>>>>> %@", message);
    }];

    [self.dataList removeObjectAtIndex:(NSUInteger) cell.indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationLeft];

    return YES;
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {
        ForumWebViewController *controller = segue.destinationViewController;

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [bundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (void)showUserProfile:(NSIndexPath *)indexPath {

    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;

    TransBundle *bundle = [[TransBundle alloc] init];
    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];

}

- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;

    [controller showLeftDrawer];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

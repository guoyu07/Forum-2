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
#import "LaiCiGouApi.h"

@interface ForumShowNewThreadPostTableViewController () <ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    UIStoryboardSegue *selectSegue;
}

@end

@implementation ForumShowNewThreadPostTableViewController{
    ViewForumPage *currentForumPage;
}


- (BOOL)autoPullfresh {
    return NO;
}

- (void)onPullRefresh {

    LaiCiGouApi * api = [[LaiCiGouApi alloc] init];
    [api getPetsOnSell:1 count:10 handler:^(id o) {

    }];
//    [self.forumApi listNewThreadWithPage:1 handler:^(BOOL isSuccess, ViewForumPage *message) {
//        [self.tableView.mj_header endRefreshing];
//        if (isSuccess) {
//            [self.tableView.mj_footer endRefreshing];
//
//            currentForumPage = message;
//
//            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
//                [self.tableView.mj_footer endRefreshingWithNoMoreData];
//            }
//
//            [self.dataList removeAllObjects];
//            [self.dataList addObjectsFromArray:message.dataList];
//            [self.tableView reloadData];
//        }
//
//    }];
}

- (void)onLoadMore {
    int toLoadPage = currentForumPage == nil ? 1 : currentForumPage.pageNumber.currentPageNumber + 1;
    [self.forumApi listNewThreadWithPage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_footer endRefreshing];
        if (isSuccess) {

            currentForumPage = message;
            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];
        }

    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SearchResultCell";
    ForumSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.showUserProfileDelegate = self;

    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
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


    Thread *play = self.dataList[(NSUInteger) indexPath.row];

    [self.forumApi favoriteThreadWithId:play.threadID handler:^(BOOL isSuccess, id message) {

    }];


    return YES;
}

- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    TransBundle * bundle = [[TransBundle alloc] init];
    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        [controller setHidesBottomBarWhenPushed:YES];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Thread *thread = self.dataList[(NSUInteger) indexPath.row];
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

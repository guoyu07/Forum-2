//
//  ForumSearchViewController.m
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSearchViewController.h"

#import "ForumSearchResultCell.h"
#import "ForumUserProfileTableViewController.h"
#import <SVProgressHUD.h>
#import "ForumWebViewController.h"

@interface ForumSearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    NSString *_searchid;
    UIStoryboardSegue *selectSegue;
    NSString *searchText;
}

@end

@implementation ForumSearchViewController

- (void)viewDidLoad {
    self.searchBar.delegate = self;

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self onLoadMore];
    }];

}

- (void)onLoadMore {

    if (_searchid == nil) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    [self.forumApi listSearchResultWithSearchid:_searchid andPage:self.currentPage + 1 handler:^(BOOL isSuccess, ViewSearchForumPage *message) {
        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {

            self.currentPage++;
            self.totalPage = (int) message.totalPageCount;

            if (self.currentPage >= self.totalPage) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.dataList addObjectsFromArray:message.threadList];
            [self.tableView reloadData];
        } else {
            NSLog(@"searchBarSearchButtonClicked   ERROR %@", message);
        }
    }];

}


#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchText = searchBar.text;

    [searchBar resignFirstResponder];

    [SVProgressHUD showWithStatus:@"搜索中" maskType:SVProgressHUDMaskTypeBlack];

    int select = (int) self.segmentedControl.selectedSegmentIndex;

    [self.forumApi searchWithKeyWord:searchText forType:select handler:^(BOOL isSuccess, ViewSearchForumPage *message) {
        [SVProgressHUD dismiss];

        if (isSuccess) {
            _searchid = message.searchid;

            self.currentPage = (int) message.currentPage;
            self.totalPage = (int) message.totalPageCount;

            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:message.threadList];
            [self.tableView reloadData];
        } else {
            NSLog(@"searchBarSearchButtonClicked   ERROR %@", message);
            NSString * msg = (NSString *)message;
            [SVProgressHUD showErrorWithStatus:msg maskType:SVProgressHUDMaskTypeBlack];
        }
    }];

}

- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    Thread *thread = self.dataList[(NSUInteger) indexPath.row];
    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:[thread.threadAuthorID intValue] forKey:@"UserId"];

    [self transBundle:bundle forController:controller];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarShouldBeginEditing");
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *QuoteCellIdentifier = @"SearchResultCell";

    ForumSearchResultCell *cell = (ForumSearchResultCell *) [tableView dequeueReusableCellWithIdentifier:QuoteCellIdentifier];
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
    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}


- (BOOL)swipeTableCell:(MGSwipeTableCellWithIndexPath *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = cell.indexPath;


    Thread *play = self.dataList[(NSUInteger) indexPath.row];

    [self.forumApi favoriteThreadPostWithId:play.threadID handler:^(BOOL isSuccess, id message) {
        BOOL success = isSuccess;
        NSString * result = message;
    }];


    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
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

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

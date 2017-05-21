//
//  ForumPrivateMessageTableViewController.m
//
//  Created by WDY on 16/3/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumPrivateMessageTableViewController.h"
#import "PrivateMessageTableViewCell.h"
#import "ForumShowPrivateMessageViewController.h"

#import "ForumUserProfileTableViewController.h"
#import "UIStoryboard+Forum.h"
#import "ForumTabBarController.h"

@interface ForumPrivateMessageTableViewController () <ThreadListCellDelegate, MGSwipeTableCellDelegate> {
    int messageType;
    UIStoryboardSegue *selectSegue;
}

@end


@implementation ForumPrivateMessageTableViewController{
    ViewForumPage *currentForumPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self isNeedHideLeftMenu]){
        self.navigationItem.leftBarButtonItem = nil;
    }

    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 97.0;

    [self.messageSegmentedControl addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)didClicksegmentedControlAction:(UISegmentedControl *)Seg {
    NSInteger index = Seg.selectedSegmentIndex;
    switch (index) {
        case 0:
            messageType = 0;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
        case 1:
            messageType = -1;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
        default:
            messageType = 0;
            [self.tableView.mj_header beginRefreshing];
            [self refreshMessage:1];
            break;
    }
}

- (void)onPullRefresh {
    [self refreshMessage:1];
}


- (void)refreshMessage:(int)page {
    [self.forumApi listPrivateMessageWithType:messageType andPage:page handler:^(BOOL isSuccess, ViewForumPage *message) {
        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {

            [self.tableView.mj_footer endRefreshing];

            currentForumPage = message;

            if (currentForumPage.pageNumber.currentPageNumber >= currentForumPage.pageNumber.totalPageNumber) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }

            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:message.dataList];

            [self.tableView reloadData];
        }
    }];
}


- (void)onLoadMore {

    int toLoadPage = currentForumPage == nil ? 1 : currentForumPage.pageNumber.currentPageNumber + 1;
    [self.forumApi listPrivateMessageWithType:messageType andPage:toLoadPage handler:^(BOOL isSuccess, ViewForumPage *message) {
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

    static NSString *identifier = @"PrivateMessageTableViewCell";
    PrivateMessageTableViewCell *cell = (PrivateMessageTableViewCell *) [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.delegate = self;
    cell.showUserProfileDelegate = self;

    Message *message = self.dataList[(NSUInteger) indexPath.row];

    [cell setData:message forIndexPath:indexPath];

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
    return cell;
}

#pragma mark CCFThreadListCellDelegate

- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;
    Message *message = self.dataList[(NSUInteger) indexPath.row];
    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:[message.pmAuthorId intValue] forKey:@"UserId"];
    [self transBundle:bundle forController:controller];
}


#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([sender isKindOfClass:[UITableViewCell class]]) {
        ForumShowPrivateMessageViewController *controller = segue.destinationViewController;


        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Message *message = self.dataList[(NSUInteger) indexPath.row];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:message forKey:@"TransPrivateMessage"];

        [self transBundle:bundle forController:controller];

    } else if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}


- (IBAction)showLeftDrawer:(id)sender {
    ForumTabBarController *controller = (ForumTabBarController *) self.tabBarController;
    
    [controller showLeftDrawer];
}

- (IBAction)writePrivateMessage:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"CreatePM"];
    [self.navigationController presentViewController:controller animated:YES completion:^{

    }];
}
@end

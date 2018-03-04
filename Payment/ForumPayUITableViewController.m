//
//  ForumPayUITableViewController.m
//  Forum
//
//  Created by WangDiyuan on 2018/2/28.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "ForumPayUITableViewController.h"
#import "ForumShowPrivatePolicyUiViewController.h"
#import "PayManager.h"
#import "LocalForumApi.h"
#import "ProgressDialog.h"

@interface ForumPayUITableViewController (){
    LocalForumApi *_localForumApi;
    PayManager *_payManager;
}

@end

@implementation ForumPayUITableViewController

- (IBAction)close:(id)sender {
    
    UINavigationController *navigationController = self.navigationController;
    [navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _localForumApi = [[LocalForumApi alloc] init];
    // payManager
    _payManager = [PayManager shareInstance];

//    if ([_payManager hasPayed:_localForumApi.currentProductID]){
//        [restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
//    } else {
//        [restorePayBtn setTitle:@"恢复之前的订阅" forState:UIControlStateNormal];
//    }

}


- (IBAction)pay:(UIBarButtonItem *)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]){
        [ProgressDialog showSuccess:@"您已订阅"];
        return;
    }

    [ProgressDialog show];

    [_payManager payForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess){
            //[restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
            [ProgressDialog showSuccess:@"订阅成功"];
        } else {
            [ProgressDialog showError:@"订阅失败"];
        }
    }];

}

- (IBAction)restorePay:(id)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]){
        [ProgressDialog showStatus:@"您已订阅"];
        return;
    }
    [ProgressDialog show];

    [_payManager restorePayForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess){
            //[restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
            [ProgressDialog showSuccess:@"订阅成功"];
        } else {
            [ProgressDialog showError:@"订阅失败"];
        }
    }];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:FALSE];

    if (indexPath.section == 0){
        if (indexPath.row == 0){
            [self pay:nil];
        } else if (indexPath.row == 2){
            [self restorePay:nil];
        }
    }
}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (BOOL)setPullRefresh:(BOOL)enable {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 3;
    } else if (section == 1){
        return 2;
    } else if (section == 2){
        return 1;
    }
    return 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * type = segue.identifier;
    if ([type isEqualToString:@"ShowTermsOfUse"] || [type isEqualToString:@"ShowPolicy"]) {
        ForumShowPrivatePolicyUiViewController *controller = segue.destinationViewController;

        TransBundle * bundle = [[TransBundle alloc] init];
        [bundle putStringValue:segue.identifier forKey:@"ShowType"];
        [self transBundle:bundle forController:controller];

    }
}

@end

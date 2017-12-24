//
//  PayViewController.m
//  
//
//  Created by 迪远 王 on 2017/12/24.
//

#import "PayViewController.h"
#import "PayManager.h"
#import "LocalForumApi.h"
#import <SVProgressHUD.h>

@interface PayViewController (){
    LocalForumApi *_localForumApi;

    IBOutlet UIButton *restorePayBtn;
    PayManager *_payManager;
}

@end

@implementation PayViewController

- (IBAction)pay:(UIBarButtonItem *)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]){
        [SVProgressHUD showSuccessWithStatus:@"您已订阅" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

    [_payManager payForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess){
            [restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
            [SVProgressHUD showSuccessWithStatus:@"订阅成功" maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showErrorWithStatus:@"订阅失败" maskType:SVProgressHUDMaskTypeBlack];
        }
    }];

}

- (IBAction)restorePay:(UIButton *)sender {

    if ([_payManager hasPayed:_localForumApi.currentProductID]){
        [SVProgressHUD showSuccessWithStatus:@"您已订阅" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

    [_payManager restorePayForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess){
            [restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
            [SVProgressHUD showSuccessWithStatus:@"订阅成功" maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showErrorWithStatus:@"订阅失败" maskType:SVProgressHUDMaskTypeBlack];
        }
    }];
}

- (IBAction)backOrDismiss:(UIBarButtonItem *)sender {
    [_payManager removeTransactionObserver];

    if (self.canBack){
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil  ];
    }
}

- (BOOL) canBack{
    return self.presentingViewController != nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _localForumApi = [[LocalForumApi alloc] init];
    // payManager
    _payManager = [PayManager shareInstance];

    if ([_payManager hasPayed:_localForumApi.currentProductID]){
        [restorePayBtn setTitle:@"您已订阅" forState:UIControlStateNormal];
    } else {
        [restorePayBtn setTitle:@"恢复之前的订阅" forState:UIControlStateNormal];
    }

    if (self.canBack) {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_arrow_back_18pt"];
    } else {
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"ic_close_18pt"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

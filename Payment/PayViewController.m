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

    PayManager *_payManager;
}
@property (strong, nonatomic) IBOutlet UIButton *restorePayButton;

@end

@implementation PayViewController

- (IBAction)pay:(UIBarButtonItem *)sender {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

    [_payManager payForProductID:_localForumApi.currentProductID with:^(BOOL isSuccess) {
        if (isSuccess){
            self.restorePayButton.titleLabel.text = @"您已订阅";
            [SVProgressHUD showSuccessWithStatus:@"订阅成功" maskType:SVProgressHUDMaskTypeBlack];
        } else {
            [SVProgressHUD showErrorWithStatus:@"订阅失败" maskType:SVProgressHUDMaskTypeBlack];
        }
    }];

}

- (IBAction)restorePay:(UIButton *)sender {

}

- (IBAction)backOrDismiss:(UIBarButtonItem *)sender {
    [_payManager removeTransactionObserver];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    _localForumApi = [[LocalForumApi alloc] init];
    // payManager
    _payManager = [PayManager shareInstance];

    if ([_payManager hasPayed:_localForumApi.currentProductID]){
        self.restorePayButton.titleLabel.text = @"您已订阅";
    } else {
        self.restorePayButton.titleLabel.text = @"恢复之前的订阅";
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

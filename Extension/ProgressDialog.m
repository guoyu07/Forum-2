//
// Created by 迪远 王 on 2018/3/4.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "ProgressDialog.h"


@implementation ProgressDialog {

}
+ (void)show {
    [SVProgressHUD setMinimumSize:CGSizeMake(100.0, 100.0)];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD show];
}

+ (void)dismiss {
    [SVProgressHUD dismiss];
}


+ (void)showStatus:(NSString *)message {
    [SVProgressHUD setMinimumSize:CGSizeMake(100.0, 100.0)];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:message];
}

+ (void)showError:(NSString *)message {
    [SVProgressHUD setMinimumSize:CGSizeMake(100.0, 100.0)];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showErrorWithStatus:message];
}

+ (void)showSuccess:(NSString *)message {
    [SVProgressHUD setMinimumSize:CGSizeMake(100.0, 100.0)];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showSuccessWithStatus:message];
}


@end
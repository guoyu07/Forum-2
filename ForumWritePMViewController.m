
//
//  ForumWritePMViewController.m
//
//  Created by 迪远 王 on 16/4/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumWritePMViewController.h"
#import <SVProgressHUD.h>


#import "TransBundleDelegate.h"

@interface ForumWritePMViewController () <TransBundleDelegate> {
    NSString *profileName;
    BOOL isReply;
    Message *_privateMessage;
}

@end


@implementation ForumWritePMViewController

// 上一Cotroller传递过来的数据
- (void)transBundle:(TransBundle *)bundle {
    if ([bundle containsKey:@"isReply"]) {
        isReply = YES;
        _privateMessage = [bundle getObjectValue:@"toReplyMessage"];


    } else {
        profileName = [bundle getStringValue:@"PROFILE_NAME"];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (isReply) {
        self.toWho.text = _privateMessage.pmAuthor;
        self.privateMessageTitle.text = [NSString stringWithFormat:@"回复：%@", _privateMessage.pmTitle];
        [self.privateMessageContent becomeFirstResponder];
    } else {
        if (profileName != nil) {
            self.toWho.text = profileName;
            [self.privateMessageTitle becomeFirstResponder];
        } else {
            [self.toWho becomeFirstResponder];
        }

    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

- (IBAction)sendPrivateMessage:(id)sender {

    if ([self.toWho.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"无收件人" maskType:SVProgressHUDMaskTypeBlack];
    } else if ([self.privateMessageTitle.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"无标题" maskType:SVProgressHUDMaskTypeBlack];
    } else if ([self.privateMessageContent.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"无内容" maskType:SVProgressHUDMaskTypeBlack];
    } else {

        [self.privateMessageContent resignFirstResponder];

        [SVProgressHUD showWithStatus:@"正在发送" maskType:SVProgressHUDMaskTypeBlack];

        if (isReply) {
            [self.forumApi replyPrivateMessageWithId:[_privateMessage.pmID intValue] andMessage:self.privateMessageContent.text handler:^(BOOL isSuccess, id message) {
                [SVProgressHUD dismiss];

                if (isSuccess) {
                    [self dismissViewControllerAnimated:YES completion:^{

                    }];
                } else {
                    [SVProgressHUD showErrorWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
                }
            }];
        } else {
            [self.forumApi sendPrivateMessageToUserName:self.toWho.text andTitle:self.privateMessageTitle.text andMessage:self.privateMessageContent.text handler:^(BOOL isSuccess, id message) {

                [SVProgressHUD dismiss];

                if (isSuccess) {
                    [self dismissViewControllerAnimated:YES completion:^{

                    }];
                } else {
                    [SVProgressHUD showErrorWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
                }

            }];
        }

    }
}

@end

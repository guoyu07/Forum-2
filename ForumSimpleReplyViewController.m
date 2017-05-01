//
//  ForumSimpleReplyViewController.m
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSimpleReplyViewController.h"
#import "SVProgressHUD.h"

#import "UIStoryboard+Forum.h"
#import "vBulletinForumEngine.h"
#import "TransBundle.h"
#import "TransBundleDelegate.h"

@interface ForumSimpleReplyViewController ()<TransBundleDelegate> {
    NSString * userName;
    int postId;
    int threadId;
    NSString *securityToken;
    NSString *ajaxLastPost;
}

@end

@implementation ForumSimpleReplyViewController

- (void)transBundle:(TransBundle *)bundle {
    userName = [bundle getStringValue:@"POST_USER"];

    threadId = [bundle getIntValue:@"THREAD_ID"];
    postId = [bundle getIntValue:@"POST_ID"];
    securityToken = [bundle getStringValue:@"SECYRITY_TOKEN"];
    ajaxLastPost = [bundle getStringValue:@"AJAX_LAST_POST"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    if (userName != nil) {
        self.replyContent.text = [NSString stringWithFormat:@"@%@\n", userName];
    }
    [self.replyContent becomeFirstResponder];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (IBAction)sendSimpleReply:(id)sender {

    [self.replyContent resignFirstResponder];

    [SVProgressHUD showWithStatus:@"正在回复" maskType:SVProgressHUDMaskTypeBlack];




    if (postId != -1) {
        [self.forumApi quickReplyPostWithThreadId:threadId forPostId:postId andMessage:self.replyContent.text securitytoken:securityToken ajaxLastPost:ajaxLastPost handler:^(BOOL isSuccess, ViewThreadPage *message) {
            if (isSuccess && message != nil) {
                [SVProgressHUD showSuccessWithStatus:@"回复成功" maskType:SVProgressHUDMaskTypeBlack];

                ViewThreadPage *thread = message;

                TransBundle * bundle = [[TransBundle alloc] init];
                [bundle putObjectValue:thread forKey:@"Simple_Reply_Callback"];

                UITabBarController * presenting = (UITabBarController *) self.presentingViewController;
                UINavigationController * selected = presenting.selectedViewController;
                UIViewController * detail = selected.topViewController;

                [self dismissViewControllerAnimated:YES backToViewController:detail withBundle:bundle completion:^{

                }];

            } else {
                [SVProgressHUD showErrorWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
            }
        }];
    } else {
        [self.forumApi replyThreadWithId:threadId andMessage:self.replyContent.text handler:^(BOOL isSuccess, id message) {

            if (isSuccess) {

                [SVProgressHUD showSuccessWithStatus:@"回复成功" maskType:SVProgressHUDMaskTypeBlack];

                self.replyContent.text = @"";

                ViewThreadPage *thread = message;

//                ForumReplyNavigationController *navigationController = (ForumReplyNavigationController *) self.navigationController;
//                self.delegate = (id <ReplyCallbackDelegate>) navigationController.controller;
//
//                [self dismissViewControllerAnimated:YES completion:^{
//                    [self.delegate transReplyValue:thread];
//                }];

            } else {
                [SVProgressHUD showErrorWithStatus:@"回复失败" maskType:SVProgressHUDMaskTypeBlack];
            }
        }];

    }

}


- (IBAction)back:(id)sender {
    [self.replyContent resignFirstResponder];

    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

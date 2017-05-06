//
//  ForumLoginViewController.m
//
//  Created by WDY on 15/12/30.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import "ForumLoginViewController.h"
#import "AppDelegate.h"

#import "UIStoryboard+Forum.h"
#import <SVProgressHUD.h>
#import "ForumCoreDataManager.h"
#import "ForumEntry+CoreDataClass.h"

@interface ForumLoginViewController () <UITextFieldDelegate> {

    CGRect screenSize;

    id<ForumBrowserDelegate> _forumApi;

}

@end

@implementation ForumLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    
    _userName.delegate = self;
    _password.delegate = self;
    _vCode.delegate = self;


    _userName.returnKeyType = UIReturnKeyNext;
    _password.returnKeyType = UIReturnKeyNext;
    _vCode.returnKeyType = UIReturnKeyDone;
    _password.keyboardType = UIKeyboardTypeASCIICapable;


    screenSize = [UIScreen mainScreen].bounds;

    _forumApi = [ForumApiHelper forumApi];

    id<ForumConfigDelegate> forumConfig = [_forumApi currentConfigDelegate];

    self.rootView.backgroundColor = forumConfig.themeColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [_forumApi refreshVCodeToUIImageView:_doorImageView];

    self.title = [[_forumApi currentConfigDelegate].forumURL.host uppercaseString];

}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _userName) {
        [_password becomeFirstResponder];
    } else if (_password == textField) {
        [_vCode becomeFirstResponder];
    } else {
        [self login:self];
    }
    return YES;
}

#pragma mark KeynboardNotification

- (void)keyboardWillShow:(id)sender {
    CGRect keyboardFrame;
    //    UIKeyboardBoundsUserInfoKey
    [[((NSNotification *) sender) userInfo][UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];

    CGRect focusedFrame = _loginbgview.frame;
    int bottom = (int) (focusedFrame.origin.y + CGRectGetHeight(focusedFrame) + self.rootView.frame.origin.y) + 20;

    int keyboardTop = (int) (CGRectGetHeight(screenSize) - CGRectGetHeight(keyboardFrame));

    if (bottom >= keyboardTop) {
        // 键盘被挡住了
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.rootView.frame;
            frame.origin.y -= (bottom - keyboardTop) + 50;
            self.rootView.frame = frame;
        }];
    }

}

- (void)keyboardWillHide:(id)sender {
    CGRect keyboardFrame;

    [[((NSNotification *) sender) userInfo][UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];


    if (self.rootView.frame.origin.y != 0) {
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.rootView.frame;
            frame.origin.y = 0;
            self.rootView.frame = frame;
        }];
    }
}


- (IBAction)login:(id)sender {


    NSString *name = _userName.text;
    NSString *password = _password.text;
    NSString *code = _vCode.text;

    [_userName resignFirstResponder];
    [_password resignFirstResponder];
    [_vCode resignFirstResponder];

    if ([name isEqualToString:@""] || [password isEqualToString:@""]) {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"\n用户名或密码为空" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

        [alert addAction:action];

        [self presentViewController:alert animated:YES completion:nil];

        return;
    }

    [SVProgressHUD showWithStatus:@"正在登录" maskType:SVProgressHUDMaskTypeBlack];

    [_forumApi loginWithName:name andPassWord:password withCode:code handler:^(BOOL isSuccess, id message) {
        if (isSuccess) {

            [_forumApi listAllForums:^(BOOL isSuccess, id message) {


                [SVProgressHUD dismiss];
                if (isSuccess) {
                    NSMutableArray<Forum *> *needInsert = message;
                    ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
                    // 需要先删除之前的老数据
                    [formManager deleteData:^NSPredicate * {
                        return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
                    }];

                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

                    [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                        ForumEntry *newsInfo = (ForumEntry *) target;
                        newsInfo.forumId = [src valueForKey:@"forumId"];
                        newsInfo.forumName = [src valueForKey:@"forumName"];
                        newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                        newsInfo.forumHost = appDelegate.forumHost;

                    }];

                    UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
                    [stortboard changeRootViewControllerTo:kForumTabBarControllerId];

                }

            }];
            
            
        } else {
            [SVProgressHUD dismiss];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:action];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

}


- (IBAction)refreshDoor:(id)sender {
    [_forumApi refreshVCodeToUIImageView:_doorImageView];
}

- (IBAction)cancelLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end

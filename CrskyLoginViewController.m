//
//  CrskyLoginViewController.m
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "CrskyLoginViewController.h"
#import "IGXMLNode+Children.h"

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSUserDefaults+Extensions.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "AppDelegate.h"
#import "UIStoryboard+Forum.h"

@interface CrskyLoginViewController ()<UIWebViewDelegate>{

}

@end

@implementation CrskyLoginViewController


- (void)viewDidLoad {
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.webView setOpaque:NO];

    
    
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://bbs.crsky.com/login.php"]]];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

// private
- (void)saveUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] saveUserName:name];
}

- (NSString*) getResponseHTML:(UIWebView *)webView {
    NSString *lJs = @"document.documentElement.outerHTML";
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:lJs];
    return html;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *html = [self getResponseHTML:webView];

    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];

    NSLog(@"CrskyLogin.webViewDidFinishLoad->%@", currentURL);

    // 使用JS注入获取用户输入的密码
    NSString * userName = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByName('pwuser')[0].value"];
    NSLog(@"CrskyLogin.userName->%@", userName);
    if (userName != nil) {
        // 保存用户名
        [self saveUserName:userName];
    }

    if ([currentURL isEqualToString:@"http://bbs.crsky.com/index.php"]){

        // 保存Cookie
        [self saveCookie];

        [self.forumApi listAllForums:^(BOOL isSuccess, id msg) {
            if (isSuccess) {
                NSMutableArray<Forum *> *needInsert = msg;
                ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
                // 需要先删除之前的老数据
                [formManager deleteData:^NSPredicate * {
                    return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
                }];

                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

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
    }

    NSLog(@"CrskyLogin.webViewDidFinishLoad %@ ", html);


}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    NSString *html = [self getResponseHTML:webView];
    NSLog(@"CrskyLogin.webViewDidStartLoad %@ ", html);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"CrskyLogin.shouldStartLoadWithRequest %@ ", urlString);

    if ([request.URL.host containsString:@"baidu.com"]) {
        return NO;
    }
    return YES;
}

- (IBAction)cancelLogin:(id)sender {
    [[NSUserDefaults standardUserDefaults] clearCurrentForumURL];
    [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
}
@end

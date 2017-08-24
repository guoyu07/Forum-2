//
// Created by 迪远 王 on 2017/5/7.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "ForumLoginWebViewController.h"
#import "IGXMLNode+Children.h"

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSUserDefaults+Extensions.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "AppDelegate.h"
#import "UIStoryboard+Forum.h"
#import "LocalForumApi.h"

@interface ForumLoginWebViewController () <UIWebViewDelegate> {

}

@end

@implementation ForumLoginWebViewController {

}

- (void)viewDidLoad {
    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

//    for (UIView *view in [[self.webView subviews][0] subviews]) {
//        if ([view isKindOfClass:[UIImageView class]]) {
//            view.hidden = YES;
//        }
//    }
    [self.webView setOpaque:NO];

    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.chiphell.com/member.php?mod=logging&action=login&mobile=2"]]];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

// private
- (void)saveUserName:(NSString *)name {
    id<ForumConfigDelegate> config = [ForumApiHelper forumConfig];
    [[NSUserDefaults standardUserDefaults] saveUserName:name forHost:config.forumURL.host];
}

- (NSString*) getResponseHTML:(UIWebView *)webView {
    NSString *lJs = @"document.documentElement.outerHTML";
    NSString *html = [webView stringByEvaluatingJavaScriptFromString:lJs];
    return html;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    NSString *html = [self getResponseHTML:webView];

    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    if ([currentURL isEqualToString:@"https://www.chiphell.com/member.php?mod=logging&action=login&mobile=2"]){
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('footer')[0].style.visibility='hidden';"
                "document.getElementsByClassName('header')[0].innerHTML='';"];
    } else if ([currentURL isEqualToString:@"https://www.chiphell.com/forum.php?mobile=yes"]){

        IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
        IGXMLNode *logined = [document queryNodeWithXPath:@"/html/body/div[3]/div[1]/a[1]"];
        NSString *userName = [[logined text] trim];

        if (userName != nil) {
            // 保存Cookie
            [self saveCookie];
            // 保存用户名
            [self saveUserName:userName];
        }

        [self.forumApi listAllForums:^(BOOL isSuccess, id msg) {
            if (isSuccess) {
                NSMutableArray<Forum *> *needInsert = msg;
                ForumCoreDataManager *formManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
                // 需要先删除之前的老数据
                [formManager deleteData:^NSPredicate * {
                    return [NSPredicate predicateWithFormat:@"forumHost = %@", self.currentForumHost];;
                }];

                LocalForumApi * localeForumApi = [[LocalForumApi alloc] init];

                [formManager insertData:needInsert operation:^(NSManagedObject *target, id src) {
                    ForumEntry *newsInfo = (ForumEntry *) target;
                    newsInfo.forumId = [src valueForKey:@"forumId"];
                    newsInfo.forumName = [src valueForKey:@"forumName"];
                    newsInfo.parentForumId = [src valueForKey:@"parentForumId"];
                    newsInfo.forumHost = localeForumApi.currentForumHost;

                }];

                UIStoryboard *stortboard = [UIStoryboard mainStoryboard];
                [stortboard changeRootViewControllerTo:kForumTabBarControllerId];

            }
        }];
    }

    NSLog(@"ForumLoginWebViewController.webViewDidFinishLoad %@ ", html);
    

}

- (void)webViewDidStartLoad:(UIWebView *)webView {

    NSString *html = [self getResponseHTML:webView];
    NSLog(@"ForumLoginWebViewController.webViewDidStartLoad %@ ", html);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlString = [[request URL] absoluteString];
//    if ([urlString isEqualToString:@"https://www.chiphell.com/?mobile=2"]) {
//        NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
//    }
    NSLog(@"ForumLoginWebViewController.shouldStartLoadWithRequest %@ ", urlString);
    return YES;
}

- (IBAction)cancelLogin:(id)sender {

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    if ([bundleId isEqualToString:@"com.andforce.forum"]){
        [[NSUserDefaults standardUserDefaults] clearCurrentForumURL];
        [[UIStoryboard mainStoryboard] changeRootViewControllerTo:@"ShowSupportForums" withAnim:UIViewAnimationOptionTransitionFlipFromTop];
    } else {
        [self exitApplication];
    }
}

- (void)exitApplication {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;

    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    rotationAnimation.delegate = self;

    rotationAnimation.fillMode=kCAFillModeForwards;

    rotationAnimation.removedOnCompletion = NO;
    //旋转角度
    rotationAnimation.toValue = @((float) (M_PI / 2));
    //每次旋转的时间（单位秒）
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    //重复旋转的次数，如果你想要无数次，那么设置成MAXFLOAT
    rotationAnimation.repeatCount = 0;
    [window.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
@end

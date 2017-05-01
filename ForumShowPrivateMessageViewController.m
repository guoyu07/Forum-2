//
//  ForumShowPrivateMessageViewController.m
//
//  Created by 迪远 王 on 16/3/25.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumShowPrivateMessageViewController.h"

#import "MJRefresh.h"
#import "ForumUserProfileTableViewController.h"

#import "ForumWebViewController.h"
#import "UIStoryboard+Forum.h"
#import "AppDelegate.h"

#import "TransBundleDelegate.h"

@interface ForumShowPrivateMessageViewController () <UIWebViewDelegate, UIScrollViewDelegate, TransBundleDelegate> {

    Message *transPrivateMessage;

    UIStoryboardSegue *selectSegue;
}

@end

@implementation ForumShowPrivateMessageViewController


- (void)transBundle:(TransBundle *)bundle {
    transPrivateMessage = [bundle getObjectValue:@"TransPrivateMessage"];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataList = [NSMutableArray array];

    [self.webView setScalesPageToFit:YES];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor whiteColor];

    for (UIView *view in [[[self.webView subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) {
            view.hidden = YES;
        }
    }
    [self.webView setOpaque:NO];

    // scrollView
    self.webView.scrollView.delegate = self;

    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [self.forumApi showPrivateContentById:[transPrivateMessage.pmID intValue] handler:^(BOOL isSuccess, id message) {
            
            ViewMessagePage *content = message;
            
            NSString *postInfo = [NSString stringWithFormat:PRIVATE_MESSAGE, content.pmUserInfo.userID, content.pmUserInfo.userAvatar, content.pmUserInfo.userName, content.pmTime, content.pmContent];

            NSString *html = [NSString stringWithFormat:THREAD_PAGE, content.pmTitle, postInfo];

            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:appDelegate.forumBaseUrl]];

            [self.webView.scrollView.mj_header endRefreshing];
        }];
    }];

    [self.webView.scrollView.mj_header beginRefreshing];
}

- (void)showUserProfile:(NSIndexPath *)indexPath {
    ForumUserProfileTableViewController *controller = selectSegue.destinationViewController;

    ViewMessagePage *message = self.dataList[(NSUInteger) indexPath.row];
    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putIntValue:[message.pmUserInfo.userID intValue] forKey:@"UserId"];

    [self transBundle:bundle forController:controller];
}

- (NSDictionary *)dictionaryFromQuery:(NSString *)query usingEncoding:(NSStringEncoding)encoding {
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString *key = [[kvPair objectAtIndex:0]
                    stringByReplacingPercentEscapesUsingEncoding:encoding];
            NSString *value = [[kvPair objectAtIndex:1]
                    stringByReplacingPercentEscapesUsingEncoding:encoding];
            [pairs setObject:value forKey:key];
        }
    }

    return [NSDictionary dictionaryWithDictionary:pairs];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    if (navigationType == UIWebViewNavigationTypeLinkClicked && ([request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"])) {


        NSString *path = request.URL.path;
        if ([path rangeOfString:@"showthread.php"].location != NSNotFound) {
            // 显示帖子
            NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

            NSString *t = [query valueForKey:@"t"];


            UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

            ForumWebViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowThreadDetail"];
            TransBundle *bundle = [[TransBundle alloc] init];
            if (t) {
                [bundle putIntValue:[t intValue] forKey:@"threadID"];
            } else {
                NSString *p = [query valueForKey:@"p"];
                [bundle putIntValue:[p intValue] forKey:@"p"];
            }


            [self transBundle:bundle forController:showThreadController];
            [self.navigationController pushViewController:showThreadController animated:YES];

            return NO;
        } else {
            [[UIApplication sharedApplication] openURL:request.URL];
            return NO;
        }
    }

    if ([request.URL.scheme isEqualToString:@"avatar"]) {
        NSDictionary *query = [self dictionaryFromQuery:request.URL.query usingEncoding:NSUTF8StringEncoding];

        NSString *userid = [query valueForKey:@"userid"];


        UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
        ForumUserProfileTableViewController *showThreadController = [storyboard instantiateViewControllerWithIdentifier:@"ShowUserProfile"];

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putIntValue:[userid intValue] forKey:@"UserId"];

        [self transBundle:bundle forController:showThreadController];

        [self.navigationController pushViewController:showThreadController animated:YES];

        return NO;
    }

    return YES;
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowUserProfile"]) {
        selectSegue = segue;
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)replyPM:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];

    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"CreatePM"];

    TransBundle *bundle = [[TransBundle alloc] init];
    [bundle putObjectValue:transPrivateMessage forKey:@"toReplyMessage"];
    [bundle putIntValue:1 forKey:@"isReply"];

    [self presentViewController:(id) controller withBundle:bundle forRootController:YES animated:YES completion:^{

    }];

}

@end

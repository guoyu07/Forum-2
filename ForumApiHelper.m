//
//  ForumBrowserFactory.m
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiHelper.h"

#import "BaseForumHtmlParser.h"
#import "CCFForumBrowser.h"
#import "DRLForumBrowser.h"
#import "AppDelegate.h"
#import "CCFForumConfig.h"
#import "DRLForumConfig.h"
#import "CCFForumHtmlParser.h"
#import "DRLForumHtmlParser.h"

@implementation ForumApiHelper
+ (id <ForumBrowserDelegate>)forumApi {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    NSString * host = appDelegate.forumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"]){
        CCFForumBrowser * _ccfForumBrowser = [[CCFForumBrowser alloc] init];
        _ccfForumBrowser.configDelegate = [[CCFForumConfig alloc] init];
        _ccfForumBrowser.parserDelegate = [[CCFForumHtmlParser alloc] init];
        return _ccfForumBrowser;
    } else if ([bundleId isEqualToString:@"com.andforce.DRL"]){
        DRLForumBrowser * _drlForumBrowser = [[DRLForumBrowser alloc] init];
        _drlForumBrowser.configDelegate = [[DRLForumConfig alloc] init];
        _drlForumBrowser.parserDelegate = [[DRLForumHtmlParser alloc] init];
        return _drlForumBrowser;
    } else{
        if ([host isEqualToString:@"bbs.et8.net"]) {
            CCFForumBrowser * _ccfForumBrowser = [[CCFForumBrowser alloc] init];
            _ccfForumBrowser.configDelegate = [[CCFForumConfig alloc] init];
            _ccfForumBrowser.parserDelegate = [[CCFForumHtmlParser alloc] init];
            return _ccfForumBrowser;
        } else if ([host isEqualToString:@"dream4ever.org"]){
            DRLForumBrowser * _drlForumBrowser = [[DRLForumBrowser alloc] init];
            _drlForumBrowser.configDelegate = [[DRLForumConfig alloc] init];
            _drlForumBrowser.parserDelegate = [[DRLForumHtmlParser alloc] init];
            return _drlForumBrowser;
        }
    }
    return nil;
}

@end

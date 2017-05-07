//
//  ForumBrowserFactory.m
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiHelper.h"

#import "CCFForumApi.h"
#import "DRLForumApi.h"
#import "AppDelegate.h"
#import "CCFForumConfig.h"
#import "DRLForumConfig.h"
#import "CCFForumHtmlParser.h"
#import "DRLForumHtmlParser.h"
#import "CHHForumApi.h"
#import "CHHForumConfig.h"
#import "CHHForumHtmlParser.h"

@implementation ForumApiHelper
+ (id <ForumBrowserDelegate>)forumApi {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    NSString * host = appDelegate.forumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"]){
        CCFForumApi * _ccfForumBrowser = [[CCFForumApi alloc] initWithConfig:[[CCFForumConfig alloc] init] parser:[[CCFForumHtmlParser alloc] init]];
        return _ccfForumBrowser;
    } else if ([bundleId isEqualToString:@"com.andforce.DRL"]){
        DRLForumApi * _drlForumBrowser = [[DRLForumApi alloc] initWithConfig:[[DRLForumConfig alloc] init] parser:[[DRLForumHtmlParser alloc] init]];
        return _drlForumBrowser;
    } else{
        if ([host isEqualToString:@"bbs.et8.net"]) {
            CCFForumApi * _ccfForumBrowser = [[CCFForumApi alloc] initWithConfig:[[CCFForumConfig alloc] init] parser:[[CCFForumHtmlParser alloc] init]];
            return _ccfForumBrowser;
        } else if ([host isEqualToString:@"dream4ever.org"]){
            DRLForumApi * _drlForumBrowser = [[DRLForumApi alloc] initWithConfig:[[DRLForumConfig alloc] init] parser:[[DRLForumHtmlParser alloc] init]];

            return _drlForumBrowser;
        } else if ([host isEqualToString:@"www.chiphell.com"] || [host isEqualToString:@"chiphell.com"]){
            CHHForumApi * api = [[CHHForumApi alloc] initWithConfig:[[CHHForumConfig alloc] init] parser:[[CHHForumHtmlParser alloc] init]];
            return api;
        }
    }
    return nil;
}

@end

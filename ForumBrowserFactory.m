//
//  ForumBrowserFactory.m
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumBrowserFactory.h"

#import <AFImageDownloader.h>
#import "ForumHtmlParser.h"
#import <iOSDeviceName/iOSDeviceName.h>
#import "CCFForumBrowser.h"
#import "DRLForumBrowser.h"
#import "AppDelegate.h"
#import "CCFForumConfig.h"
#import "DRLForumConfig.h"
#import "CCFForumHtmlParser.h"
#import "DRLForumHtmlParser.h"

//static CCFForumBrowser * _ccfForumBrowser;
//static DRLForumBrowser * _drlForumBrowser;

@implementation ForumBrowserFactory
+ (id <ForumBrowserDelegate>)currentForumBrowser {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    NSString * host = appDelegate.forumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"]){
        CCFForumBrowser * _ccfForumBrowser = [[CCFForumBrowser alloc] init];
        _ccfForumBrowser.configDelegate = [[CCFForumConfig alloc] init];
        _ccfForumBrowser.htmlParser = [[CCFForumHtmlParser alloc] init];
        return _ccfForumBrowser;
    } else if ([bundleId isEqualToString:@"com.andforce.DRL"]){
        DRLForumBrowser * _drlForumBrowser = [[DRLForumBrowser alloc] init];
        _drlForumBrowser.configDelegate = [[DRLForumConfig alloc] init];
        _drlForumBrowser.htmlParser = [[DRLForumHtmlParser alloc] init];
        return _drlForumBrowser;
    } else{
        if ([host isEqualToString:@"bbs.et8.net"]) {
            CCFForumBrowser * _ccfForumBrowser = [[CCFForumBrowser alloc] init];
            _ccfForumBrowser.configDelegate = [[CCFForumConfig alloc] init];
            _ccfForumBrowser.htmlParser = [[CCFForumHtmlParser alloc] init];
            return _ccfForumBrowser;
        } else if ([host isEqualToString:@"dream4ever.org"]){
            DRLForumBrowser * _drlForumBrowser = [[DRLForumBrowser alloc] init];
            _drlForumBrowser.configDelegate = [[DRLForumConfig alloc] init];
            _drlForumBrowser.htmlParser = [[DRLForumHtmlParser alloc] init];
            return _drlForumBrowser;
        }
    }
    return nil;
}

@end

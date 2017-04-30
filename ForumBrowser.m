//
//  ForumBrowser.m
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumBrowser.h"

#import <AFImageDownloader.h>
#import "ForumHtmlParser.h"
#import <iOSDeviceName/iOSDeviceName.h>
#import "CCFForumBrowser.h"
#import "DRLForumBrowser.h"
#import "AppDelegate.h"

//static CCFForumBrowser * _ccfForumBrowser;
//static DRLForumBrowser * _drlForumBrowser;

@implementation ForumBrowser


- (id<ForumBrowserDelegate>)browserWithForumConfig:(ForumConfig *)config {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    if ([bundleId isEqualToString:@"com.andforce.et8"]){
            CCFForumBrowser * _ccfForumBrowser = [[CCFForumBrowser alloc] init];
            _ccfForumBrowser.config = config;
            _ccfForumBrowser.htmlParser = [ForumHtmlParser parserWithForumConfig:config];
        return _ccfForumBrowser;
    } else if ([bundleId isEqualToString:@"com.andforce.DRL"]){
            DRLForumBrowser * _drlForumBrowser = [[DRLForumBrowser alloc] init];
            _drlForumBrowser.config = config;
            _drlForumBrowser.htmlParser = [ForumHtmlParser parserWithForumConfig:config];
        return _drlForumBrowser;
    } else{
        if ([config.host isEqualToString:@"bbs.et8.net"]) {
                CCFForumBrowser * _ccfForumBrowser = [[CCFForumBrowser alloc] init];
                _ccfForumBrowser.config = config;
                _ccfForumBrowser.htmlParser = [ForumHtmlParser parserWithForumConfig:config];
            return _ccfForumBrowser;
        } else if ([config.host isEqualToString:@"dream4ever.org"]){
                DRLForumBrowser * _drlForumBrowser = [[DRLForumBrowser alloc] init];
                _drlForumBrowser.config = config;
                _drlForumBrowser.htmlParser = [ForumHtmlParser parserWithForumConfig:config];
            return _drlForumBrowser;
        }
        return self;
    }
    
    return self;

}

#pragma clang diagnostic push

- (id)init {

    if (self = [super init]) {
        self.browser = [AFHTTPSessionManager manager];
        self.browser.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.browser.responseSerializer.acceptableContentTypes = [self.browser.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [self.browser.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36" forHTTPHeaderField:@"User-Agent"];

        self.phoneName = [DeviceName deviceNameDetail];
    }

    return self;
}

#pragma clang diagnostic pop


@end

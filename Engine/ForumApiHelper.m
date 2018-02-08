//
//  ForumBrowserFactory.m
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiHelper.h"

#import "AppDelegate.h"
#import "CrskyForumApi.h"
#import "CrskyForumConfig.h"
#import "LocalForumApi.h"

typedef id (^Runnable)(NSString *bundle, NSString *host);

@implementation ForumApiHelper
+ (id <ForumBrowserDelegate>)forumApi:(NSString *)host {
    CrskyForumApi *crskyForumApi = [[CrskyForumApi alloc] init];
    return crskyForumApi;
}

+ (id <ForumConfigDelegate>)forumConfig:(NSString *)host {
    CrskyForumConfig *crskyForumApi = [[CrskyForumConfig alloc] init];
    return crskyForumApi;
}


+ (id <ForumConfigDelegate>)forumConfig {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString * host = localForumApi.currentForumHost;

    CrskyForumConfig *crskyForumApi = [[CrskyForumConfig alloc] init];
    return crskyForumApi;
}

+ (id <ForumBrowserDelegate>)forumApi {

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString * host = localForumApi.currentForumHost;

    CrskyForumApi *crskyForumApi = [[CrskyForumApi alloc] init];
    return crskyForumApi;
}


@end

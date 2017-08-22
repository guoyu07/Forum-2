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
#import "CHHForumApi.h"
#import "CrskyForumApi.h"

@implementation ForumApiHelper
+ (id <ForumBrowserDelegate>)forumApi {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    NSString * host = appDelegate.forumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"] || [host isEqualToString:@"bbs.et8.net"]){

        CCFForumApi * ccfForumApi = [[CCFForumApi alloc] init];
        return ccfForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.DRL"] || [host isEqualToString:@"dream4ever.org"]){

        DRLForumApi * drlForumApi = [[DRLForumApi alloc] init];
        return drlForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:@"bbs.crsky.com"]){

        CrskyForumApi *crskyForumApi = [[CrskyForumApi alloc] init];
        return crskyForumApi;

    } else if([bundleId isEqualToString:@"com.andforce.CHH"] || [host isEqualToString:@"www.chiphell.com"] || [host isEqualToString:@"chiphell.com"]){

        CHHForumApi * chhForumApi = [[CHHForumApi alloc] init];
        return chhForumApi;

    }
    return nil;
}

@end

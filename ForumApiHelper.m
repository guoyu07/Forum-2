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
#import "CCFForumConfig.h"
#import "DRLForumConfig.h"
#import "CrskyForumConfig.h"
#import "CHHForumConfig.h"
#import "LocalForumApi.h"

typedef id (^Runnable)(NSString *bundle, NSString *host);

@implementation ForumApiHelper
+ (id <ForumBrowserDelegate>)forumApi:(NSString *)host {
    if ([host isEqualToString:@"bbs.et8.net"]){

        CCFForumApi * ccfForumApi = [[CCFForumApi alloc] init];
        return ccfForumApi;

    } else if ([host isEqualToString:@"dream4ever.org"]){

        DRLForumApi * drlForumApi = [[DRLForumApi alloc] init];
        return drlForumApi;

    } else if ([host isEqualToString:@"bbs.crsky.com"]){

        CrskyForumApi *crskyForumApi = [[CrskyForumApi alloc] init];
        return crskyForumApi;

    } else if([host isEqualToString:@"chiphell.com"]){

        CHHForumApi * chhForumApi = [[CHHForumApi alloc] init];
        return chhForumApi;

    }
    return nil;
}

+ (id <ForumConfigDelegate>)forumConfig:(NSString *)host {
    if ([host isEqualToString:@"bbs.et8.net"]){

        CCFForumConfig * ccfForumApi = [[CCFForumConfig alloc] init];
        return ccfForumApi;

    } else if ([host isEqualToString:@"dream4ever.org"]){

        DRLForumConfig * drlForumApi = [[DRLForumConfig alloc] init];
        return drlForumApi;

    } else if ([host isEqualToString:@"bbs.crsky.com"]){

        CrskyForumConfig *crskyForumApi = [[CrskyForumConfig alloc] init];
        return crskyForumApi;

    } else if([host isEqualToString:@"chiphell.com"]){

        CHHForumConfig * chhForumApi = [[CHHForumConfig alloc] init];
        return chhForumApi;

    }

    return nil;
}


+ (id <ForumConfigDelegate>)forumConfig {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString * host = localForumApi.currentForumHost;

    if ([bundleId isEqualToString:@"com.andforce.et8"] || [host isEqualToString:@"bbs.et8.net"]){

        CCFForumConfig * ccfForumApi = [[CCFForumConfig alloc] init];
        return ccfForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.DRL"] || [host isEqualToString:@"dream4ever.org"]){

        DRLForumConfig * drlForumApi = [[DRLForumConfig alloc] init];
        return drlForumApi;

    } else if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:@"bbs.crsky.com"]){

        CrskyForumConfig *crskyForumApi = [[CrskyForumConfig alloc] init];
        return crskyForumApi;

    } else if([bundleId isEqualToString:@"com.andforce.CHH"] || [host isEqualToString:@"www.chiphell.com"] || [host isEqualToString:@"chiphell.com"]){

        CHHForumConfig * chhForumApi = [[CHHForumConfig alloc] init];
        return chhForumApi;

    }
    return nil;
}

+ (id <ForumBrowserDelegate>)forumApi {

    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *bundleId = [localForumApi bundleIdentifier];
    NSString * host = localForumApi.currentForumHost;

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

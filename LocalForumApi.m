//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "LocalForumApi.h"
#import "LoginUser.h"
#import "NSUserDefaults+Extensions.h"
#import "ForumConfigDelegate.h"
#import "ForumApiHelper.h"
#import "BaseForumApi.h"


@implementation LocalForumApi {
    id <ForumConfigDelegate> forumConfig;
}

- (instancetype)init {
    self = [super init];
    if (self){
        BaseForumApi * api = (BaseForumApi *)[ForumApiHelper forumApi];
        forumConfig = api.forumConfig;
    }
    return self;
}
- (LoginUser *)getLoginUser {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [[NSUserDefaults standardUserDefaults] userName];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:forumConfig.cookieUserIdKey]) {
            user.userID = [cookie.value componentsSeparatedByString:@"%"][0];
        } else if ([cookie.name isEqualToString:forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}

- (BOOL)isHaveLogin:(NSString *)host {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    NSDate *date = [NSDate date];
    for (NSHTTPCookie * cookie in cookies) {
        if ([cookie.domain containsString:host] && [cookie.expiresDate compare:date] != NSOrderedAscending){
            return YES;
        }
    }
    return NO;
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults] clearCookie];

    NSURL *url = forumConfig.forumURL;
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) cookies[(NSUInteger) i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

@end
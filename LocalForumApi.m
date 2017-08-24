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
#import "AppDelegate.h"
#import "Forums.h"
#import "SupportForums.h"


@implementation LocalForumApi {
    //id <ForumConfigDelegate> forumConfig;
}


- (LoginUser *)getLoginUserCrsky {

    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0){
        return nil;
    }

    id <ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig];
    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [[NSUserDefaults standardUserDefaults] userName:@"bbs.crsky.com"];
    if (user.userName == nil || [user.userName isEqualToString:@""]){
        return nil;
    }
    user.userID = [[NSUserDefaults standardUserDefaults] userId];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}

- (LoginUser *)getLoginUser:(NSString *)host {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0){
        return nil;
    }
    id <ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *bundleId = [appDelegate bundleIdentifier];

    if ([bundleId isEqualToString:@"com.andforce.Crsky"] || [host isEqualToString:@"bbs.crsky.com"]){
        return [self getLoginUserCrsky];
    } else {
        LoginUser *user = [[LoginUser alloc] init];
        user.userName = [[NSUserDefaults standardUserDefaults] userName:host];
        if (user.userName == nil || [user.userName isEqualToString:@""]){
            return nil;
        }

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
}

- (BOOL)isHaveLogin:(NSString *)host {

    LoginUser *user = [self getLoginUser:host];
    if (user == nil){
        return NO;
    }

    if (user.userName == nil || user.userID == nil || user.expireTime == nil){
        return NO;
    }
    if ([user.userName isEqualToString:@""] || [user.userID isEqualToString:@""] || [user.expireTime compare:[NSDate date]] == NSOrderedAscending){
        return NO;
    }
    return YES;
}

- (void)logout {
    id <ForumConfigDelegate> forumConfig = [ForumApiHelper forumConfig];

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

- (NSString *)currentForumHost {
    NSString * urlStr = [[NSUserDefaults standardUserDefaults] currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (NSArray<Forums *> *)supportForums {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"supportForums" ofType:@"json"]];

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions) kNilOptions error:nil];

    SupportForums *supportForums = [SupportForums modelObjectWithDictionary:dictionary];
    return supportForums.forums;
}

- (NSString *)currentForumBaseUrl {
    NSString *urlstr = [NSUserDefaults standardUserDefaults].currentForumURL;
    return urlstr;
}


@end

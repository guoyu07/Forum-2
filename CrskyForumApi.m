//
//  CrskyForumApi.m
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "CrskyForumApi.h"
#import "ForumParserDelegate.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import "DeviceName.h"
#import "NSUserDefaults+Extensions.h"
#import "ForumCoreDataManager.h"
#import "NSString+Extensions.h"

@implementation CrskyForumApi

// private
- (NSString *)loadCookie {
    return [[NSUserDefaults standardUserDefaults] loadCookie];
}

// private
- (void)saveUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] saveUserName:name];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

// private
- (NSString *)buildSignature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 霏凡客户端", phoneName];
    return signature;
}

- (LoginUser *)getLoginUser {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [[NSUserDefaults standardUserDefaults] userName];
    user.userID = [[NSUserDefaults standardUserDefaults] userId];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:self.forumConfig.cookieExpTimeKey]) {
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

    NSURL *url = self.forumConfig.forumURL;
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) cookies[(NSUInteger) i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void)listAllForums:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [self.browser GETWithURLString:self.forumConfig.archive parameters:parameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString * host = self.forumConfig.forumURL.host;
            NSArray<Forum *> *parserForums = [self.forumParser parserForums:html forumHost:host];
            if (parserForums != nil && parserForums.count > 0) {
                handler(YES, parserForums);
            } else {
                handler(NO, html);
            }
        } else {
            handler(NO, html);
        }
    }];
}

- (void)fetchUserId:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    NSString * url = self.forumConfig.forumURL.absoluteString;
    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            NSString *uid = [html stringWithRegular:@"(?<=UID: )\\d+"];
            handler(isSuccess, uid);
        } else {
            handler(NO, html);
        }

    }];
}

- (void)createNewThreadWithForumId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {

}

- (void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler {

}

- (void)seniorReplyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)replyPostId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler {

}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {

}

- (void)showPrivateMessageContentWithId:(int)pmId handler:(HandlerWithBool)handler {

}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)favoriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

    NSString *key = [self.forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];
    NSArray * favForumIds = [data componentsSeparatedByString:@","];
    NSLog(@"favoriteForumsWithId \t%@", favForumIds);
    if (![favForumIds containsObject:forumId]){
        NSMutableArray * array = [favForumIds mutableCopy];
        [array addObject:forumId];

        // 存到云端
        NSString * newForums = [array componentsJoinedByString:@","];
        [store setString:newForums forKey:key];
        [store synchronize];
        
        // 存到本地
        NSMutableArray * ids = [NSMutableArray array];
        for (NSString *fid in favForumIds){
            [ids addObject:@([fid intValue])];
        }
        [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];
    }

    handler(YES, @"SUCCESS");

}

- (void)unfavouriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *key = [self.forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];
    NSArray * favForumIds = [data componentsSeparatedByString:@","];
    NSLog(@"favoriteForumsWithId \t%@", favForumIds);
    if ([favForumIds containsObject:forumId]){
        NSMutableArray * array = [favForumIds mutableCopy];
        [array removeObject:forumId];

        // 存到云端
        NSString * newForums = [array componentsJoinedByString:@","];
        [store setString:newForums forKey:key];
        [store synchronize];

        // 存到本地
        NSMutableArray * ids = [NSMutableArray array];
        for (NSString *fid in favForumIds){
            [ids addObject:@([fid intValue])];
        }
        [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];
    }

    handler(YES, @"SUCCESS");
}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listFavoriteForums:(HandlerWithBool)handler {

    NSString *key = [self.forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];
    NSArray * favForumIds = [data componentsSeparatedByString:@","];
    NSMutableArray * ids = [NSMutableArray array];
    for (NSString *forumId in favForumIds){
        [ids addObject:@([forumId intValue])];
    }
    [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];

    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    NSArray *forms = [[manager selectFavForums:ids] mutableCopy];

    handler(YES, forms);
}

- (void)listFavoriteThreadWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];

    NSInteger searchId = [userDefault integerForKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
    NSInteger lastTimeStamp = [userDefault integerForKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];

    // 参数
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    long spaceTime = timeStamp - lastTimeStamp;
    if (searchId == 0 || spaceTime > 60 * 10) {

        [self.browser GETWithURLString:[self.forumConfig searchNewThread:page] parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSUInteger newThreadPostSearchId = (NSUInteger) [[self.forumParser parseListMyThreadSearchId:html] integerValue];
                [userDefault setInteger:timeStamp forKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];
                [userDefault setInteger:newThreadPostSearchId forKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
            }
            if (isSuccess) {
                ViewSearchForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchIdStr = [NSString stringWithFormat:@"%ld", (long) searchId];
        NSString *url = [self.forumConfig searchWithSearchId:searchIdStr withPage:page];

        [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    NSString * url = [self.forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];
    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            ViewThreadPage *detail = [self.forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
        }

    }];
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {

}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    NSString*url = [self.forumConfig forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page];
    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [self.forumParser parseUserAvatar:html userId:userId];
        if (!avatar){
            avatar = self.forumConfig.avatarNo;
        }
        NSLog(@"getAvatarWithUserId \t%@", avatar);
        handler(isSuccess, avatar);
    }];
}

- (void)listSearchResultWithSearchId:(NSString *)searchid andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [self.forumParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (id <ForumConfigDelegate>)currentConfigDelegate {
    return self.forumConfig;
}


@end

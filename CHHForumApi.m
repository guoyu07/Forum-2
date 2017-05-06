//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "CHHForumApi.h"
#import "NSUserDefaults+Extensions.h"
#import "DeviceName.h"


@implementation CHHForumApi {

}
- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString *)code handler:(HandlerWithBool)handler {

}

- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView {

}

- (LoginUser *)getLoginUser {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [self userName:self.currentConfigDelegate.forumURL.host];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:self.forumConfig.cookieLastVisitTimeKey]) {
            user.lastVisit = cookie.value;
        } else if ([cookie.name isEqualToString:self.forumConfig.cookieUserIdKey]) {
            user.userID = cookie.value;
        } else if ([cookie.name isEqualToString:self.forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}

- (BOOL)isHaveLogin:(NSString *)host {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    NSDate *date = [NSDate date];
    for (NSHTTPCookie * cookie in cookies) {
        if ([host isEqualToString:cookie.domain] && [cookie.expiresDate compare:date] != NSOrderedAscending){
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

}

- (void)createNewThreadWithForumId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {

}

- (void)replyThreadWithId:(int)threadId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler {

}

- (void)seniorReplyWithThreadId:(int)threadId forForumId:(int)forumId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler {

}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {

}

- (void)showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler {

}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)favoriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)unfavouriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listFavoriteForums:(HandlerWithBool)handler {

}

- (void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listTodayNewThreadsWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listMyAllThreadPost:(HandlerWithBool)handler {

}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {

}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {

}

- (void)listSearchResultWithSearchid:(NSString *)searchid andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {

}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (id <ForumConfigDelegate>)currentConfigDelegate {
    return self.forumConfig;
}

//------
// private
- (NSString *)loadCookie {
    return [[NSUserDefaults standardUserDefaults] loadCookie];
}

// private
- (void)saveUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] saveUserName:name];
}

//private
- (NSString *)userName:(NSString *)host {
    return [[NSUserDefaults standardUserDefaults] userName:host];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

// private
- (NSString *)buildSignature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 CCF客户端", phoneName];
    return signature;
}

//------

@end
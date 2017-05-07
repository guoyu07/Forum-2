//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "CHHForumConfig.h"


@implementation CHHForumConfig {

}
- (UIColor *)themeColor {
    return [UIColor redColor];
}

- (NSURL *)forumURL {
    return [NSURL URLWithString:@"https://chiphell.com/"];
}

- (NSString *)archive {
    return @"https://www.chiphell.com/archiver/";
}

- (NSString *)cookieUserIdKey {
    return nil;
}

- (NSString *)cookieLastVisitTimeKey {
    return nil;
}

- (NSString *)cookieExpTimeKey {
    return nil;
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return nil;
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return nil;
}

- (NSString *)newattachment {
    return nil;
}

- (NSString *)search {
    return nil;
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return nil;
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)searchMyPostWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)searchMyThreadWithUserName:(NSString *)name {
    return nil;
}

- (NSString *)favForumWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return nil;
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return nil;
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    return nil;
}

- (NSString *)unfavThreadWithId:(NSString *)threadId {
    return nil;
}

- (NSString *)listfavThreadWithId:(int)page {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return nil;
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return nil;
}

- (NSString *)searchNewThread {
    return nil;
}

- (NSString *)searchNewThreadToday {
    return nil;
}

- (NSString *)newReplyWithThreadId:(int)threadId {
    return nil;
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId {
    return nil;
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return nil;
}

- (NSString *)showThreadWithPostId:(NSString *)postId withPostCout:(int)postCount {
    return nil;
}

- (NSString *)showThreadWithP:(NSString *)p {
    return nil;
}

- (NSString *)avatar:(NSString *)avatar {
    return nil;
}

- (NSString *)avatarBase {
    return nil;
}

- (NSString *)avatarNo {
    return nil;
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return nil;
}

- (NSString *)login {
    return @"https://www.chiphell.com/member.php?mod=logging&action=login&referer=https%3A%2F%2Fwww.chiphell.com%2Fforum.php&cookietime=1";
}

- (NSString *)loginvCode {
    return nil;
}

- (NSString *)newThreadWithForumId:(NSString *)forumId {
    return nil;
}

- (NSString *)privateWithType:(int)type withPage:(int)page {
    return nil;
}

- (NSString *)privateShowWithMessageId:(int)messageId {
    return nil;
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return nil;
}

- (NSString *)privateReplyWithMessage {
    return nil;
}

- (NSString *)privateNewPre {
    return nil;
}

- (NSString *)usercp {
    return nil;
}

- (NSString *)report {
    return nil;
}

- (NSString *)reportWithPostId:(int)postId {
    return nil;
}

- (NSString *)loginControllerId {
    return @"LoginForumWebView";
}


@end
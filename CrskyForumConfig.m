//
//  CrskyForumConfig.m
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "CrskyForumConfig.h"

@implementation CrskyForumConfig{
    NSURL *_forumURL;
}

- (instancetype)init {
    self = [super init];
    _forumURL = [NSURL URLWithString:@"http://bbs.crsky.com/"];
    return self;
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:101.f/255.f green:96.f/255.f blue:65.f/255.f alpha:1];;
}

- (NSURL *)forumURL {
    return _forumURL;
}

- (NSString *)archive {
    return @"http://bbs.crsky.com/simple/";
}

- (NSString *)cookieUserIdKey {
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
    return [NSString stringWithFormat:@"http://bbs.crsky.com/search.php?step=2&sid=%@&seekfid=all&page=%d", searchId, page];
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
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
    return [NSString stringWithFormat:@"http://bbs.crsky.com/thread.php?fid=%@&page=%d", forumId, page];
}

- (NSString *)searchNewThread:(int)page {
    return @"http://bbs.crsky.com/search.php?sch_time=all&orderway=lastpost&asc=desc&newatc=1";
}

- (NSString *)replyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)postId {
    return nil;
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/read.php?tid=%@&fpage=0&toread=&page=%d",threadId, page];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return nil;
}

- (NSString *)copyThreadUrl:(NSString *)postId withPostCout:(int)postCount {
    return nil;
}

- (NSString *)avatar:(NSString *)avatar {
    return avatar;
}

- (NSString *)avatarBase {
    return nil;
}

- (NSString *)avatarNo {
    return nil;
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"http://bbs.crsky.com/u.php?action=show&uid=%@",userId];
}

- (NSString *)login {
    return nil;
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

- (NSString *)favoriteForums {
    return nil;
}

- (NSString *)report {
    return nil;
}

- (NSString *)reportWithPostId:(int)postId {
    return nil;
}

- (NSString *)loginControllerId {
    return @"CrskyLoginViewController";
}


@end

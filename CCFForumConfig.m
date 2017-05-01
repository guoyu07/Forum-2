//
//  CCFForumConfig.m
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFForumConfig.h"

@implementation CCFForumConfig {
    NSURL *url;
}

- (instancetype)init {
    self = [super init];
    url = [NSURL URLWithString:@"https://bbs.et8.net/bbs/"];

    return self;
}

- (NSString *)host {
    return url.host;
}

- (NSString *)cookieUserIdKey {
    return @"bbuserid";
}

- (NSString *)cookieLastVisitTimeKey {
    return @"bblastvisit";
}

- (NSString *)cookieExpTimeKey {
    return @"IDstack";
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:46.f/255.f green:70.f/255.f blue:126.f/255.f alpha:1];
}

- (NSURL *)forumURL {
    return url;
}


- (NSString *)archive {
    return [url.absoluteString stringByAppendingString:@"archive/index.php"];
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?t=%d&poststarttime=%@&posthash=%@", url.absoluteString, threadId, time, postHash];
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?f=%d&poststarttime=%@&posthash=%@", url.absoluteString, forumId, time, postHash];
}

- (NSString *)newattachment {
    return [NSString stringWithFormat:@"%@newattachment.php", url.absoluteString];
}

- (NSString *)search {
    return [url.absoluteString stringByAppendingString:@"search.php"];
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:@"%@search.php?searchid=%@&pp=30&page=%d",url.absoluteString, searchId, page];
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@search.php?do=finduser&u=%@&starteronly=1", url.absoluteString ,userId];
}

- (NSString *)searchMyPostWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@search.php?do=finduser&userid=%@", url.absoluteString ,userId];
}

- (NSString *)searchMyThreadWithUserName:(NSString *)name {
    return [NSString stringWithFormat:@"%@search.php?do=process&showposts=0&starteronly=1&exactname=1&searchuser=%@", url.absoluteString ,name];
}

- (NSString *)favForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&f=%@", url.absoluteString,forumId];
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&forumid=%@",url.absoluteString,forumId];
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&f=%@",url.absoluteString, forumId];
}

- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&t=%@",url.absoluteString, threadId];
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&threadid=%@", url.absoluteString, threadId];
}

- (NSString *)unfavThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&t=%@",url.absoluteString, threadId];
}

- (NSString *)listfavThreadWithId:(int)page {
    return [NSString stringWithFormat:@"%@subscription.php?do=viewsubscription&pp=35&folderid=0&sort=lastpost&order=desc&page=%d", url.absoluteString, page];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@", url.absoluteString, forumId];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@&order=desc&page=%d", url.absoluteString, forumId, page];
}

- (NSString *)searchNewThread {
    return [NSString stringWithFormat:@"%@search.php?do=getnew", url.absoluteString];
}

- (NSString *)searchNewThreadToday {
    return [NSString stringWithFormat:@"%@search.php?do=getdaily",url.absoluteString];
}

- (NSString *)newReplyWithThreadId:(int)threadId {
    return [NSString stringWithFormat:@"%@newreply.php?do=postreply&t=%d",url.absoluteString, threadId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@showthread.php?t=%@",url.absoluteString, threadId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"%@showthread.php?t=%@&page=%d",url.absoluteString, threadId, page];
}

- (NSString *)showThreadWithPostId:(NSString *)postId withPostCout:(int)postCount {
    return [NSString stringWithFormat:@"%@showpost.php?p=%@&postcount=%d",url.absoluteString, postId, postCount];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return [NSString stringWithFormat:@"%@showthread.php?p=%@",url.absoluteString, p];
}

- (NSString *)avatar:(NSString *)avatar {
    return [NSString stringWithFormat:@"%@customavatars%@",url.absoluteString, avatar];
}

- (NSString *)avatarBase {
    return [url.absoluteString stringByAppendingString:@"customavatars"];
}

- (NSString *)avatarNo {
    return [[self avatarBase] stringByAppendingString:@"/no_avatar.gif"];
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@member.php?u=%@", url.absoluteString, userId];
}

- (NSString *)login {
    return [NSString stringWithFormat:@"%@login.php?do=login", url.absoluteString];
}

- (NSString *)loginvCode {
    return [NSString stringWithFormat:@"%@login.php?do=vcode", url.absoluteString];
}

- (NSString *)newThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@newthread.php?do=newthread&f=%@", url.absoluteString,forumId];
}

- (NSString *)privateWithType:(int)type withPage:(int)page {
    return [NSString stringWithFormat:@"%@private.php?folderid=%d&pp=30&sort=date&page=%d", url.absoluteString,type, page];
}

- (NSString *)privateShowWithMessageId:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=showpm&pmid=%d", url.absoluteString,messageId];
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=%d", url.absoluteString,messageId];
}

- (NSString *)privateReplyWithMessage {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=0", url.absoluteString];
}

- (NSString *)privateNewPre {
    return [NSString stringWithFormat:@"%@private.php?do=newpm", url.absoluteString];
}

- (NSString *)usercp {
    return [NSString stringWithFormat:@"%@usercp.php", url.absoluteString];
}

- (NSString *)report {
    return [NSString stringWithFormat:@"%@report.php?do=sendemail", url.absoluteString];
}

- (NSString *)reportWithPostId:(int)postId {
    return [NSString stringWithFormat:@"%@report.php?p=%d", url.absoluteString,postId];
}

@end

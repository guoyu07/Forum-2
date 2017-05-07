//
//  CCFForumConfig.m
//  Forum
//
//  Created by WDY on 2016/12/8.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "DRLForumConfig.h"

@implementation DRLForumConfig {
    NSURL *_forumURL;
}

- (instancetype)init {
    self = [super init];
    _forumURL = [NSURL URLWithString:@"https://dream4ever.org/"];
    return self;
}

- (NSString *)host {
    return _forumURL.host;
}

- (NSString *)cookieUserIdKey {
    return @"drluserid";
}

- (NSString *)cookieLastVisitTimeKey {
    return @"drllastvisit";
}

- (NSString *)cookieExpTimeKey {
    return @"IDstack";
}

- (UIColor *)themeColor {
    return [[UIColor alloc] initWithRed:111.f/255.f green:134.f/255.f blue:160.f/255.f alpha:1];
}

- (NSURL *)forumURL {
    return _forumURL;
}


- (NSString *)archive {
    return [_forumURL.absoluteString stringByAppendingString:@"forumdisplay.php?f=1"];
}

- (NSString *)newattachmentForThread:(int)threadId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?t=%d&poststarttime=%@&posthash=%@", _forumURL.absoluteString, threadId, time, postHash];
}

- (NSString *)newattachmentForForum:(int)forumId time:(NSString *)time postHash:(NSString *)postHash {
    return [NSString stringWithFormat:@"%@newattachment.php?f=%d&poststarttime=%@&posthash=%@", _forumURL.absoluteString, forumId, time, postHash];
}

- (NSString *)newattachment {
    return [NSString stringWithFormat:@"%@newattachment.php", _forumURL.absoluteString];
}

- (NSString *)search {
    return [_forumURL.absoluteString stringByAppendingString:@"search.php"];
}

- (NSString *)searchWithSearchId:(NSString *)searchId withPage:(int)page {
    return [NSString stringWithFormat:@"%@search.php?searchid=%@&pp=30&page=%d",_forumURL.absoluteString, searchId, page];
}

- (NSString *)searchThreadWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@search.php?do=finduser&u=%@&starteronly=1", _forumURL.absoluteString ,userId];
}

- (NSString *)searchMyPostWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@search.php?do=finduser&userid=%@", _forumURL.absoluteString ,userId];
}

- (NSString *)searchMyThreadWithUserName:(NSString *)name {
    return [NSString stringWithFormat:@"%@search.php?do=process&showposts=0&starteronly=1&exactname=1&searchuser=%@", _forumURL.absoluteString ,name];
}

- (NSString *)favForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&f=%@", _forumURL.absoluteString,forumId];
}

- (NSString *)favForumWithIdParam:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&forumid=%@",_forumURL.absoluteString,forumId];
}

- (NSString *)unfavForumWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&f=%@",_forumURL.absoluteString, forumId];
}

- (NSString *)favThreadWithIdPre:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=addsubscription&t=%@",_forumURL.absoluteString, threadId];
}

- (NSString *)favThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=doaddsubscription&threadid=%@", _forumURL.absoluteString, threadId];
}

- (NSString *)unfavThreadWithId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@subscription.php?do=removesubscription&t=%@",_forumURL.absoluteString, threadId];
}

- (NSString *)listfavThreadWithId:(int)page {
    return [NSString stringWithFormat:@"%@subscription.php?do=viewsubscription&pp=35&folderid=0&sort=lastpost&order=desc&page=%d", _forumURL.absoluteString, page];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@", _forumURL.absoluteString, forumId];
}

- (NSString *)forumDisplayWithId:(NSString *)forumId withPage:(int)page {
    return [NSString stringWithFormat:@"%@forumdisplay.php?f=%@&order=desc&page=%d", _forumURL.absoluteString, forumId, page];
}

- (NSString *)searchNewThread {
    return [NSString stringWithFormat:@"%@search.php?do=getnew", _forumURL.absoluteString];
}

- (NSString *)searchNewThreadToday {
    return [NSString stringWithFormat:@"%@search.php?do=getdaily",_forumURL.absoluteString];
}

- (NSString *)newReplyWithThreadId:(int)threadId {
    return [NSString stringWithFormat:@"%@newreply.php?do=postreply&t=%d",_forumURL.absoluteString, threadId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId {
    return [NSString stringWithFormat:@"%@showthread.php?t=%@",_forumURL.absoluteString, threadId];
}

- (NSString *)showThreadWithThreadId:(NSString *)threadId withPage:(int)page {
    return [NSString stringWithFormat:@"%@showthread.php?t=%@&page=%d",_forumURL.absoluteString, threadId, page];
}

- (NSString *)showThreadWithPostId:(NSString *)postId withPostCout:(int)postCount {
    return [NSString stringWithFormat:@"%@showpost.php?p=%@&postcount=%d",_forumURL.absoluteString, postId, postCount];
}

- (NSString *)showThreadWithP:(NSString *)p {
    return [NSString stringWithFormat:@"%@showthread.php?p=%@",_forumURL.absoluteString, p];
}

- (NSString *)avatar:(NSString *)avatar {
    return [NSString stringWithFormat:@"%@customavatars%@",_forumURL.absoluteString, avatar];
}

- (NSString *)avatarBase {
    return [_forumURL.absoluteString stringByAppendingString:@"customavatars"];
}

- (NSString *)avatarNo {
    return [[self avatarBase] stringByAppendingString:@"/no_avatar.gif"];
}

- (NSString *)memberWithUserId:(NSString *)userId {
    return [NSString stringWithFormat:@"%@member.php?u=%@", _forumURL.absoluteString, userId];
}

- (NSString *)login {
    return [NSString stringWithFormat:@"%@login.php?do=login", _forumURL.absoluteString];
}

- (NSString *)loginvCode {
    return [NSString stringWithFormat:@"%@login.php?do=vcode", _forumURL.absoluteString];
}

- (NSString *)newThreadWithForumId:(NSString *)forumId {
    return [NSString stringWithFormat:@"%@newthread.php?do=newthread&f=%@", _forumURL.absoluteString,forumId];
}

- (NSString *)privateWithType:(int)type withPage:(int)page {
    return [NSString stringWithFormat:@"%@private.php?folderid=%d&pp=30&sort=date&page=%d", _forumURL.absoluteString,type, page];
}

- (NSString *)privateShowWithMessageId:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=showpm&pmid=%d", _forumURL.absoluteString,messageId];
}

- (NSString *)privateReplyWithMessageIdPre:(int)messageId {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=%d", _forumURL.absoluteString,messageId];
}

- (NSString *)privateReplyWithMessage {
    return [NSString stringWithFormat:@"%@private.php?do=insertpm&pmid=0", _forumURL.absoluteString];
}

- (NSString *)privateNewPre {
    return [NSString stringWithFormat:@"%@private.php?do=newpm", _forumURL.absoluteString];
}

- (NSString *)usercp {
    return [NSString stringWithFormat:@"%@usercp.php", _forumURL.absoluteString];
}

- (NSString *)report {
    return [NSString stringWithFormat:@"%@report.php?do=sendemail", _forumURL.absoluteString];
}

- (NSString *)reportWithPostId:(int)postId {
    return [NSString stringWithFormat:@"%@report.php?p=%d", _forumURL.absoluteString,postId];
}

- (NSString *)loginControllerId {
    return @"LoginForum";
}


@end

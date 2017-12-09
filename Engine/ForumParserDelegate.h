//
//  ForumParserDelegate.h
//  vBulletinForumEngine
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginUser.h"
#import "Message.h"
#import "ViewMessagePage.h"
#import "Post.h"
#import "User.h"
#import "Forum.h"
#import "Thread.h"
#import "UserProfile.h"
#import "ViewThreadPage.h"
#import "ViewForumPage.h"
#import "ViewSearchForumPage.h"
#import "PageNumber.h"

@protocol ForumParserDelegate <NSObject>

@required
// 页面相关
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html;

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop;

- (ViewForumPage *)parseFavorThreadListFromHtml:(NSString *)html;

@optional
- (ViewForumPage *)parseListMyAllThreadsFromHtml:(NSString *)html;

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int) type;

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html;

- (ViewSearchForumPage *)parseZhanNeiSearchPageFromHtml:(NSString *)html type:(int) type;

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *) avatarBase noavatar:(NSString *) avatarNO;

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId;

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *) host;

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html;

// 动作相关
- (PageNumber *) parserPageNumber:(NSString *)html;

- (NSString *)parseQuickReplyQuoteContent:(NSString *)html;

- (NSString *)parseQuickReplyTitle:(NSString *)html;

- (NSString *)parseQuickReplyTo:(NSString *)html;

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId;

- (NSString *)parseListMyThreadSearchId:(NSString *)html;

@required
- (NSString *)parseErrorMessage:(NSString *)html;

// vBulletin
- (NSString *)parseSecurityToken:(NSString *)html;

- (NSString *)parsePostHash:(NSString *)html;

- (NSString *)parserPostStartTime:(NSString *)html;

- (NSString *)parseLoginErrorMessage:(NSString *)html;

- (NSString *)parseQuote:(NSString *)html;
@end

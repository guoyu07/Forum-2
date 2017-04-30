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
#import "SimpleThread.h"
#import "NormalThread.h"
#import "ViewThreadPage.h"
#import "ViewForumPage.h"
#import "ThreadInSearch.h"
#import "ViewSearchForumPage.h"

@protocol ForumParserDelegate <NSObject>

@required
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html;

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop;

- (ViewForumPage *)parseFavThreadListFromHtml:(NSString *)html;

- (NSString *)parseSecurityToken:(NSString *)html;

- (NSString *)parsePostHash:(NSString *)html;

- (NSString *)parserPostStartTime:(NSString *)html;

- (NSString *)parseLoginErrorMessage:(NSString *)html;

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html;

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html;

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html;

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html;

- (NSString *)parseQuickReplyQuoteContent:(NSString *)html;

- (NSString *)parseQuickReplyTitle:(NSString *)html;

- (NSString *)parseQuickReplyTo:(NSString *)html;

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId;

- (NSString *)parseListMyThreadSearchid:(NSString *)html;

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId;

- (NSArray<Forum *> *)parserForums:(NSString *)html;

@end

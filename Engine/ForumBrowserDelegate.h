//
//  ForumApi.h
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginUser.h"
#import "ViewForumPage.h"
#import "ViewSearchForumPage.h"
#import "ForumConfigDelegate.h"
#import "Forum.h"
#import "vBulletinDelegate.h"
#import "DiscuzDelegate.h"
#import "PhpWindDelegate.h"

@class ViewThreadPage;
@class ViewMessagePage;
@class Message;
@class ForumWebViewController;

typedef void (^HandlerWithBool)(BOOL isSuccess, id message);

typedef void (^UserInfoHandler)(BOOL isSuccess, id userName, id userId);

@protocol ForumBrowserDelegate <vBulletinDelegate, DiscuzDelegate, PhpWindDelegate>

// 获取所有的论坛列表
- (void)listAllForums:(HandlerWithBool)handler;

// 发表新帖子时候，支持的主题分类
@required
- (void)listThreadCategory:(NSString *)fid handler:(HandlerWithBool)handler;

// 发表一个新的帖子
@required
- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *) page handler:(HandlerWithBool)handler;

// 快速回复
//- (void)quickReplyPostWithMessage:(NSString *)message toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler;

// 带有图片回复
- (void)seniorReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId  thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler;

// 引用回复楼层
- (void)quoteReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId  thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler;


// 搜索论坛
// 0.标题 1. 内容 2. 用户
- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler;

// 根据PM ID 显示一条私信内容
// 0 系统短信   1 正常私信
- (void)showPrivateMessageContentWithId:(int)pmId withType:(int ) type handler:(HandlerWithBool)handler;

// 发送站内短信
- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler;

// 回复站内短信
- (void)replyPrivateMessage:(Message *)privateMessage andReplyContent:(NSString *)content handler:(HandlerWithBool)handler;

// 收藏这个论坛
- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler;

// 取消收藏论坛
- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler;

// 收藏一个主题帖子
- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler;

// 取消收藏一个主题帖子
- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler;

// 读取论坛站内私信List   type 0 表示收件箱   -1表示发件箱
- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler;

// 删除一条站内信 type 0 表示收件箱   -1表示发件箱
@required
- (void)deletePrivateMessage:(Message *)privateMessage withType:(int)type handler:(HandlerWithBool)handler;

// 获取收藏的论坛板块
- (void)listFavoriteForums:(HandlerWithBool)handler;

// 获取收藏的主题帖子
- (void)listFavoriteThreads:(int)userId withPage:(int) page handler:(HandlerWithBool)handler;

// 查看新帖
- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler;

// 显示我发表的主题
- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler;

// 显示用户发表的主题
- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler;

// 显示主题帖子和所有回帖
- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler;

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler;

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler;

- (void)listSearchResultWithSearchId:(NSString *)searchId keyWord:(NSString *)keyWord andPage:(int)page type:(int)type  handler:(HandlerWithBool)handler;

// 显示用户信息页面
- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler;

// 举报违规帖子
- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler;

@required
- (BOOL) openUrlByClient:(ForumWebViewController *) controller request:(NSURLRequest *)request;

@end

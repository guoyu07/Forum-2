//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ForumConfigDelegate.h"
#import "AFImageDownloader.h"

@protocol ForumParserDelegate;
@class LoginUser;

@interface BaseForumApi : NSObject

-(id)initWithConfig:(id <ForumConfigDelegate>)configDelegate parser:(id<ForumParserDelegate>) parserDelegate;

-(id <ForumConfigDelegate>)forumConfig;
-(id <ForumParserDelegate>)forumParser;

-(AFHTTPSessionManager *)browser;

// 获取当前登录的账户信息
- (LoginUser *)getLoginUser;

// 获取当前登录的账户信息
- (BOOL)isHaveLogin:(NSString *) host;

// 退出论坛
- (void)logout;

@end

//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginUser;
@class Forums;


@interface LocalForumApi : NSObject

// 获取当前登录的账户信息
- (LoginUser *)getLoginUser:(NSString *)host;

// 获取当前登录的账户信息
- (BOOL)isHaveLogin:(NSString *) host;

// 退出论坛
- (void)logout;

- (NSString *)currentForumHost;

- (NSArray<Forums *> *) supportForums;

- (NSString *)currentForumBaseUrl;

@end
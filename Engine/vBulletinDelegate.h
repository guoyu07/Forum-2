//
// Created by 迪远 王 on 2017/8/22.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^HandlerWithBool)(BOOL isSuccess, id message);

@protocol vBulletinDelegate <NSObject>

// 登录论坛
@optional
- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString*) code question:(NSString *) q answer:(NSString *) a handler:(HandlerWithBool)handler;

// 刷新验证码
@optional
- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView;

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler;

@end
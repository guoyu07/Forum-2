//
// Created by 迪远 王 on 2018/3/4.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProgressDialog : NSObject

+ (void)show;

+ (void)dismiss;

+ (void)showStatus:(NSString *)message;

+ (void)showError:(NSString *)message;

+ (void)showSuccess:(NSString *)message;

@end
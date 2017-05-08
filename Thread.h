//
//  Thread.h
//
//  Created by WDY on 16/3/15.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleThread.h"

@interface Thread : SimpleThread

@property(nonatomic, strong) NSString *postCount;          // 回复数
@property(nonatomic, strong) NSString *openCount;          // 查看数量
@property(nonatomic, strong) NSString *lastPostAuthorName; // 最后发表的人
@property(nonatomic, assign) int totalPostPageCount;       // 回帖页数

// 搜索页面
@property(nonatomic, strong) NSString *fromFormName;       // 所属论坛名称

@end

//
//  Thread.h
//
//  Created by WDY on 16/3/15.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Thread : NSObject

@property(nonatomic, strong) NSString *postCount;          // 回复数
@property(nonatomic, strong) NSString *openCount;          // 查看数量
@property(nonatomic, strong) NSString *lastPostAuthorName; // 最后发表的人
@property(nonatomic, assign) int totalPostPageCount;       // 回帖页数

@property(nonatomic, strong) NSString *threadID;
@property(nonatomic, strong) NSString *threadTitle;        // 主题
@property(nonatomic, strong) NSString *threadAuthorName;   // 作者
@property(nonatomic, strong) NSString *threadAuthorID;     // ---------------- 作者UserId
@property(nonatomic, strong) NSString *lastPostTime;       // 最后发表时间
@property(nonatomic, assign) BOOL isGoodNess;              // 是否是精华帖子
@property(nonatomic, assign) BOOL isContainsImage;         // 是否包含图片

// 搜索页面
@property(nonatomic, strong) NSString *fromFormName;       // 所属论坛名称

@property(nonatomic, assign) BOOL isTopThread;             // 是否置顶帖子

@end

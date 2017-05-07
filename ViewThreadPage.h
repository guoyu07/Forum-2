//
//  ViewThreadPage.h
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"

@interface ViewThreadPage : NSObject

@property(nonatomic, strong) NSString *threadID;

@property(nonatomic, assign) BOOL isCanReply;

@property(nonatomic, strong) NSString *threadTitle;
@property(nonatomic, strong) NSString *forumId;            // 主题所属论坛


@property(nonatomic, strong) NSString *originalHtml;

@property(nonatomic, assign) NSUInteger totalPageCount;
@property(nonatomic, assign) NSUInteger currentPage;

@property(nonatomic, strong) NSMutableArray<Post *> *postList;

@property(nonatomic, strong) NSString *securityToken;
@property(nonatomic, strong) NSString *ajaxLastPost;


@end

//
//  ViewThreadPage.h
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "PageNumber.h"

@interface ViewThreadPage : NSObject

@property(nonatomic, assign) int threadID;

@property(nonatomic, assign) BOOL isCanReply;

@property(nonatomic, strong) NSString *threadTitle;
@property(nonatomic, assign) int forumId;            // 主题所属论坛


@property(nonatomic, strong) NSString *originalHtml;

@property(nonatomic, strong) PageNumber *pageNumber;

@property(nonatomic, strong) NSMutableArray<Post *> *postList;

@property(nonatomic, strong) NSString *securityToken;   // forumhash
@property(nonatomic, strong) NSString *ajaxLastPost;


@end

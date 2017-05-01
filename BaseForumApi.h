//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "vBulletinForumEngine.h"
#import "ForumConfigDelegate.h"

@class AFHTTPSessionManager;
@class BaseForumHtmlParser;

@interface BaseForumApi : NSObject

@property(nonatomic, strong) id<ForumConfigDelegate> configDelegate;
@property(nonatomic, strong) id<ForumParserDelegate> parserDelegate;

@property(nonatomic, strong) AFHTTPSessionManager *browser;

-(id)initWithConfig:(id <ForumConfigDelegate>)configDelegate parser:(id<ForumParserDelegate>) parserDelegate;

@end

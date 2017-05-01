//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "vBulletinForumEngine.h"
#import "ForumConfigDelegate.h"
#import <AFImageDownloader.h>

@interface BaseForumApi : NSObject

-(id)initWithConfig:(id <ForumConfigDelegate>)configDelegate parser:(id<ForumParserDelegate>) parserDelegate;

-(id <ForumConfigDelegate>)forumConfig;
-(id <ForumParserDelegate>)forumParser;

-(AFHTTPSessionManager *)browser;
@end

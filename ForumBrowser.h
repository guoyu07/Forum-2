//
//  ForumBrowser.h
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vBulletinForumEngine.h"
#import "ForumConfig.h"

@class AFHTTPSessionManager;
@class ForumHtmlParser;


@interface ForumBrowser : NSObject

- (id <ForumBrowserDelegate>) browserWithForumConfig:(ForumConfig *)config;

@property(nonatomic, strong) ForumConfig *config;

@property(nonatomic, strong) NSString *phoneName;
@property(nonatomic, strong) ForumHtmlParser *htmlParser;
@property(nonatomic, strong) AFHTTPSessionManager *browser;

@end

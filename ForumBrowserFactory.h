//
//  ForumBrowserFactory.h
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vBulletinForumEngine.h"
#import "ForumConfig.h"

@class AFHTTPSessionManager;
@class ForumHtmlParser;


@interface ForumBrowserFactory : NSObject

+ (id <ForumBrowserDelegate>) currentForumBrowser;

@end

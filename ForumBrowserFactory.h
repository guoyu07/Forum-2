//
//  ForumBrowserFactory.h
//
//  Created by 迪远 王 on 16/10/3.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vBulletinForumEngine.h"
#import "ForumConfigDelegate.h"
#import "ForumBrowserDelegate.h"
#import "ForumParserDelegate.h"

@class AFHTTPSessionManager;
@class BaseForumHtmlParser;


@interface ForumBrowserFactory : NSObject

+ (id <ForumBrowserDelegate>) currentForumBrowser;

@end

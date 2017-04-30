//
//  ForumHtmlParser.h
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vBulletinForumEngine.h"

#import "ForumConfig.h"

@interface ForumHtmlParser : NSObject <ForumParserDelegate>

+ (instancetype)parserWithForumConfig:(ForumConfig *)config;

@property (nonatomic, strong) ForumConfig *config;
@end

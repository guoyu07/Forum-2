//
//  BaseForumHtmlParser.h
//
//  Created by 迪远 王 on 16/10/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "vBulletinForumEngine.h"

#import "ForumConfigDelegate.h"

@interface BaseForumHtmlParser : NSObject

@property(nonatomic, strong) id<ForumConfigDelegate> configDelegate;

@end

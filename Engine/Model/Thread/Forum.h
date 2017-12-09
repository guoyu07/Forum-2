//
//  Forum.h
//
//  Created by 迪远 王 on 16/1/23.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Forum : NSObject

@property(nonatomic, assign) int forumId;
@property(nonatomic, strong) NSString *forumName;
@property(nonatomic, strong) NSString *forumHost;
@property(nonatomic, assign) int parentForumId;

@property(nonatomic, strong) NSArray<Forum *> *childForums;

@end

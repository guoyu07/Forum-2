//
//  ForumThreadListForChildFormUITableViewController.h
//
//  Created by 迪远 王 on 16/3/27.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiBaseTableViewController.h"
#import "ForumApiBaseTableViewController.h"


@interface ForumThreadListForChildFormUITableViewController : ForumApiBaseTableViewController

// 置顶
@property(nonatomic, strong) NSMutableArray *threadTopList;

- (IBAction)back:(UIBarButtonItem *)sender;

- (IBAction)createThread:(id)sender;


@end

//
//  ForumBaseStaticTableViewController.h
//
//  Created by 迪远 王 on 16/10/9.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumBrowserFactory.h"
#import "MJRefresh.h"
#import "vBulletinForumEngine.h"

@interface ForumBaseStaticTableViewController : UITableViewController

@property(nonatomic, assign) id<ForumBrowserDelegate> forumBrowser;
@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, assign) int currentPage;
@property(nonatomic, assign) int totalPage;

- (void)onPullRefresh;


- (void)onLoadMore;

- (BOOL)setPullRefresh:(BOOL)enable;

- (BOOL)setLoadMore:(BOOL)enable;

- (BOOL)autoPullfresh;

- (NSString *) currentForumHost;

@end

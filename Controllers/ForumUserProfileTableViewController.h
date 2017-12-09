//
//  ForumUserProfileTableViewController.h
//
//  Created by 迪远 王 on 16/3/20.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumApiBaseTableViewController.h"

@interface ForumUserProfileTableViewController : ForumApiBaseTableViewController

@property(weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property(weak, nonatomic) IBOutlet UILabel *userName;
@property(weak, nonatomic) IBOutlet UILabel *userRankName;
@property(weak, nonatomic) IBOutlet UILabel *userSignDate;
@property(weak, nonatomic) IBOutlet UILabel *userCurrentLoginDate;
@property(weak, nonatomic) IBOutlet UILabel *userPostCount;


- (IBAction)back:(id)sender;

@end

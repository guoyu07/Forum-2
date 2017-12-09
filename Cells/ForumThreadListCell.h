//
//  ForumThreadListCell.h
//
//  Created by 迪远 王 on 16/1/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFourmTableViewCell.h"


@interface ForumThreadListCell : BaseFourmTableViewCell


@property(weak, nonatomic) IBOutlet UILabel *threadAuthor;
@property(weak, nonatomic) IBOutlet UILabel *threadTitle;
@property(weak, nonatomic) IBOutlet UILabel *threadPostCount;
@property(weak, nonatomic) IBOutlet UILabel *threadOpenCount;
@property(weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property(weak, nonatomic) IBOutlet UILabel *threadCreateTime;
@property(weak, nonatomic) IBOutlet UILabel *threadType;
@property(weak, nonatomic) IBOutlet UILabel *threadTopFlag;
@property(weak, nonatomic) IBOutlet UIImageView *threadContainsImage;


- (IBAction)showUserProfile:(UIButton *)sender;

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath;
@end

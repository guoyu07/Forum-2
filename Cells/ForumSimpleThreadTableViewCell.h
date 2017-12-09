//
//  ForumSimpleThreadTableViewCell.h
//
//  Created by WDY on 16/3/17.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFourmTableViewCell.h"

@interface ForumSimpleThreadTableViewCell : BaseFourmTableViewCell

@property(weak, nonatomic) IBOutlet UILabel *threadAuthorName;
@property(weak, nonatomic) IBOutlet UILabel *lastPostTime;
@property(weak, nonatomic) IBOutlet UILabel *threadTitle;
@property(weak, nonatomic) IBOutlet UIImageView *ThreadAuthorAvatar;
@property(weak, nonatomic) IBOutlet UILabel *threadCategory;

- (IBAction)showUserProfile:(UIButton *)sender;

@end

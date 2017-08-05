//
//  PrivateMessageTableViewCell.h
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSString+Extensions.h"
#import "UIImageView+AFNetworking.h"
#import "ForumCoreDataManager.h"
#import "UserEntry+CoreDataProperties.h"
#import "ForumApiHelper.h"
#import "BaseFourmTableViewCell.h"

@interface PrivateMessageTableViewCell : BaseFourmTableViewCell

@property(weak, nonatomic) IBOutlet UILabel *privateMessageTitle;
@property(weak, nonatomic) IBOutlet UILabel *privateMessageAuthor;
@property(weak, nonatomic) IBOutlet UILabel *privateMessageTime;
@property(weak, nonatomic) IBOutlet UIImageView *privateMessageAuthorAvatar;

- (IBAction)showUserProfile:(UIButton *)sender;

@end

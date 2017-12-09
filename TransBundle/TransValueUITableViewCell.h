//
//  TransValueUITableViewCell.h
//
//  Created by 迪远 王 on 16/3/29.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCellWithIndexPath.h"

@protocol ThreadListCellDelegate <NSObject>

@required
- (void)showUserProfile:(NSIndexPath *)indexPath;

@end


@interface TransValueUITableViewCell : MGSwipeTableCellWithIndexPath

@property(weak, nonatomic) id <ThreadListCellDelegate> showUserProfileDelegate;

@end

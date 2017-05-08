//
//  ForumSearchResultCell.h
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseFourmTableViewCell.h"


@interface ForumSearchResultCell : BaseFourmTableViewCell


@property(weak, nonatomic) IBOutlet UILabel *postTitle;
@property(weak, nonatomic) IBOutlet UILabel *postAuthor;
@property(weak, nonatomic) IBOutlet UILabel *postTime;
@property(weak, nonatomic) IBOutlet UILabel *postBelongForm;
@property(weak, nonatomic) IBOutlet UIImage *postAuthorAvatar;

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath;

- (IBAction)showUserProfile:(UIButton *)sender;

@end

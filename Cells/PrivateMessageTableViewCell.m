//
//  PrivateMessageTableViewCell.m
//
//  Created by 迪远 王 on 16/3/13.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "PrivateMessageTableViewCell.h"

@implementation PrivateMessageTableViewCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {

        UIEdgeInsets edgeInset = self.separatorInset;
        edgeInset.left = 40 + 8 + 8;
        [self setSeparatorInset:edgeInset];

    }
    return self;
}

- (void)setData:(Message *)data {


    [self.privateMessageTitle setText:data.pmTitle];
    if (!data.isReaded) {
        self.privateMessageTitle.font = [UIFont boldSystemFontOfSize:17.0];
        self.privateMessageTitle.textColor = [UIColor blackColor];
    } else {
        self.privateMessageTitle.font = [UIFont fontWithName:@"Helvetica Neue" size:17.0];
        self.privateMessageTitle.textColor = [UIColor grayColor];
    }


    [self.privateMessageAuthor setText:data.pmAuthor];
    [self.privateMessageTime setText:data.pmTime];
    [self showAvatar:self.privateMessageAuthorAvatar userId:data.pmAuthorId];

}

- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    self.selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:self.selectIndexPath];
}
@end

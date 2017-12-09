//
//  ForumSearchResultCell.m
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumSearchResultCell.h"


@implementation ForumSearchResultCell {
    NSIndexPath *selectIndexPath;
}


- (void)setData:(Thread *)data {


    self.postTitle.text = data.threadTitle;
    self.postAuthor.text = data.threadAuthorName;
    self.postTime.text = data.lastPostTime;
    self.postBelongForm.text = data.fromFormName;

    [self showAvatar:self.postAuthorAvatar userId:data.threadAuthorID];
}


- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}

@end

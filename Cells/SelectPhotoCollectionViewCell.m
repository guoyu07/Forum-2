//
//  SelectPhotoCollectionViewCell.m
//
//  Created by WDY on 16/1/14.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "SelectPhotoCollectionViewCell.h"

@implementation SelectPhotoCollectionViewCell {
    NSIndexPath *path;
}

- (void)setData:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    path = indexPath;
    self.imageView.image = image;
}

- (IBAction)deleteCurrentImage:(UIButton *)sender {
    [self.deleteImageDelete deleteCurrentImageForIndexPath:path];
}
@end

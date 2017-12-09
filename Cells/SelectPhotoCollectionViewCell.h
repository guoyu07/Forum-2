//
//  SelectPhotoCollectionViewCell.h
//
//  Created by WDY on 16/1/14.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DeleteDelegate <NSObject>

@required
- (void)deleteCurrentImageForIndexPath:(NSIndexPath *)indexPath;

@end


@interface SelectPhotoCollectionViewCell : UICollectionViewCell

@property(nonatomic, weak) id <DeleteDelegate> deleteImageDelete;

@property(weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)setData:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath;

- (IBAction)deleteCurrentImage:(UIButton *)sender;

@end

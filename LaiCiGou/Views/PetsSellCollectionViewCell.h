//
//  PetsSellCollectionViewCell.h
//  Forum
//
//  Created by 迪远 王 on 2018/2/8.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PetsSellCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *dogImage;
@property (strong, nonatomic) IBOutlet UILabel *typeTextView;
@property (strong, nonatomic) IBOutlet UILabel *daiTextView;
@property (strong, nonatomic) IBOutlet UILabel *petsIdTextView;
@property (strong, nonatomic) IBOutlet UILabel *priceTextView;

@end

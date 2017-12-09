//
//  XibInflater.m
//
//  Created by 迪远 王 on 16/4/10.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "XibInflater.h"

@implementation XibInflater

+ (id)inflateViewByXibName:(NSString *)xibName {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];

    return [nib objectAtIndex:0];
}
@end

//
//  LoginUser.h
//
//  Created by 迪远 王 on 16/2/28.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUser : NSObject

@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *userID;

@property(nonatomic, strong) NSDate *expireTime;

@end
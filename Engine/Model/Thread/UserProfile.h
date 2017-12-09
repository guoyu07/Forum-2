//
//  UserProfile.h
//
//  Created by 迪远 王 on 16/3/20.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property(nonatomic, strong) NSString *profileUserId;
@property(nonatomic, strong) NSString *profileRank;
@property(nonatomic, strong) NSString *profileName;
@property(nonatomic, strong) NSString *profileRegisterDate;
@property(nonatomic, strong) NSString *profileRecentLoginDate;
@property(nonatomic, strong) NSString *profileTotalPostCount;


@end

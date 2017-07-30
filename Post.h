//
//  Post.h
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface Post : NSObject

@property(nonatomic, strong) NSString *postID;          //1. postId

@property(nonatomic, strong) NSString *postLouCeng;     //2. 帖子楼层
@property(nonatomic, strong) NSString *postTime;        //3. 帖子时间
@property(nonatomic, strong) NSString *postContent;     //4. content html

@property(nonatomic, strong) User *postUserInfo;        //5. user

@end

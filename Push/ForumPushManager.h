//
// Created by 迪远 王 on 2017/12/9.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVOSCloud/AVOSCloud.h>


@interface ForumPushManager : NSObject

- (void) registerPushManagerWithOptions:(NSDictionary *)launchOptions;

- (void) handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

@end
//
//  LaiCiGouApi.h
//  Forum
//
//  Created by WangDiyuan on 2018/2/8.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

typedef void (^LaiCiGouHandler)(id);

@interface LaiCiGouApi : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *browser;

- (void) getPetsOnSell:(int)page count:(int) count handler:(LaiCiGouHandler) handler;

@end

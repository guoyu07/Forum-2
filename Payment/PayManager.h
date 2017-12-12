//
// Created by WDY on 2017/12/12.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PayManager : NSObject

+ (instancetype)shareInstance;

- (void)payForProductID:(NSString *)productID;

- (BOOL)hasPayed:(NSString *)productID;

- (void)removeTransactionObserver;

@end
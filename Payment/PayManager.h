//
// Created by WDY on 2017/12/12.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PayManager : NSObject

typedef void (^PayHandler)(BOOL isSuccess);

+ (instancetype)shareInstance;

- (void)verifyPay:(NSString *)productID;

- (void)payForProductID:(NSString *)productID with:(PayHandler) handler;

- (void)restorePayForProductID:(NSString *)productID with:(PayHandler) handler;

- (BOOL)hasPayed:(NSString *)productID;

- (void)removeTransactionObserver;

@end
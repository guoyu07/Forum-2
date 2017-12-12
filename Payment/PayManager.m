//
// Created by WDY on 2017/12/12.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "PayManager.h"
#import <StoreKit/StoreKit.h>

@interface PayManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate> {

    NSString *_currentProductID;
}

@end

@implementation PayManager {

}

static PayManager *_instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}

- (void)payForProductID:(NSString *)productID {

    _currentProductID = productID;

    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductData:_currentProductID];
    } else {
        NSLog(@"应用没有开启内购权限");
    }
}


- (instancetype)init {
    if (self = [super init]) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;

}

- (BOOL)hasPayed:(NSString *)productID {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:productID];
}

// remove all payment queue
- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


- (void)requestProductData:(NSString *)productID {

    NSLog(@"-------------请求对应的产品信息----------------");

//    [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeBlack];

    NSArray *product = @[productID];

    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];

}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased: {
                NSLog(@"交易完成");
                // 发送到苹果服务器验证凭证
                [self verifyPurchaseWithPaymentTransaction:_currentProductID];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];

            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");

                break;
            case SKPaymentTransactionStateRestored: {
                NSLog(@"已经购买过商品");

                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed: {
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                //[SVProgressHUD showErrorWithStatus:@"购买失败"];
            }
                break;
            default:
                break;
        }
    }
}

// request Failed
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError ：%@", error.localizedDescription);
}

// request Response
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response {
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if ([product count] == 0) {
        //[SVProgressHUD dismiss];
        NSLog(@"--------------没有商品------------------");
        return;
    }

    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu", (unsigned long) [product count]);

    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);

        if ([pro.productIdentifier isEqualToString:_currentProductID]) {
            p = pro;
        }
    }

    SKPayment *payment = [SKPayment paymentWithProduct:p];

    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"

// 验证购买，避免越狱软件模拟苹果请求达到非法购买问题
- (void)verifyPurchaseWithPaymentTransaction:(NSString *)productID {
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];

    NSString *receiptString = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串

    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\", \"password\":\"%@\"}",
                    receiptString, @"b3189c215c0b423d985bc8d2548bb91a"];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];


    //创建请求到苹果官方进行购买验证
    NSURL *url = [NSURL URLWithString:SANDBOX];
    NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody = bodyData;
    requestM.HTTPMethod = @"POST";
    //创建连接并发送同步请求
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@", error.localizedDescription);
        return;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@", dic);
    if ([dic[@"status"] intValue] == 0) {

        NSLog(@"购买成功！\t%@", dic);

        NSDictionary *dicReceipt = dic[@"receipt"];
        NSDictionary *dicInApp = [dicReceipt[@"in_app"] firstObject];
        NSString *productIdentifier = dicInApp[@"product_id"];//读取产品标识
        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([productIdentifier isEqualToString:productID]) {
            NSUInteger purchasedCount = (NSUInteger) [defaults integerForKey:productIdentifier];//已购买数量
            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount + 1) forKey:productIdentifier];
        } else {
            [defaults setBool:YES forKey:productIdentifier];
        }
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    } else {
        NSLog(@"购买失败，未通过验证！");
    }
}

@end

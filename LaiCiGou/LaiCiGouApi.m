//
//  LaiCiGouApi.m
//  Forum
//
//  Created by WangDiyuan on 2018/2/8.
//  Copyright © 2018年 andforce. All rights reserved.
//

#import "LaiCiGouApi.h"
#import "AFHTTPSessionManager.h"
#import "AFHTTPSessionManager+SimpleAction.h"

@implementation LaiCiGouApi

- (void)getPetsOnSell:(int)page count:(int)count handler:(LaiCiGouHandler)handler {

    [_browser.requestSerializer setValue:@"" forHTTPHeaderField:@"User-Agent"];
    
//    builder.host("https://pet-chain.baidu.com/");
//    builder.path("data/market/queryPetsOnSale");
//    builder.method("POST");

    [_browser.requestSerializer setValue:@"pet-chain.baidu.com" forHTTPHeaderField:@"Host"];
    [_browser.requestSerializer setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [_browser.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [_browser.requestSerializer setValue:@"https://pet-chain.baidu.com" forHTTPHeaderField:@"Origin"];
    [_browser.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [_browser.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_browser.requestSerializer setValue:@"1" forHTTPHeaderField:@"DNT"];
    [_browser.requestSerializer setValue:@"https://pet-chain.baidu.com/" forHTTPHeaderField:@"Referer"];
    [_browser.requestSerializer setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
    [_browser.requestSerializer setValue:@"zh-CN,zh;q=0.9,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
    [_browser.requestSerializer setValue:@"BIDUPSID=2912576290A31870B509702CE524D314; PSTM=1513673325; BAIDUID=97382737C6B3B77EEBDAE9C8650202E7:FG=1; H_PS_PSSID=1428_21096_17001_22158; BDORZ=B490B5EBF6F3CD402E515D22BCDA1598; FP_UID=6e686ace6d2388db8612dc735e69c110; BDUSS=VIZEVwSWlPdVhsMUdSVWY1bnVVeXo4ZnJlTUVaaGlXS0JBSEYtd2c5a3k5NkZhQVFBQUFBJCQAAAAAAAAAAAEAAACFcFMHQW5kZm9yY2UAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADJqeloyanpaZX; BDRCVFR[feWj1Vr5u3D]=I67x6TjHwwYf0; PSINO=1" forHTTPHeaderField:@"Cookie"];

    //builder.postJsonBody("{\"pageNo\":" + 1 +",\"pageSize\":10,\"querySortType\":\"AMOUNT_ASC\",\"petIds\":[],\"lastAmount\":null,\"lastRareDegree\":null,\"requestId\":" + 1 + ",\"appId\":1,\"tpl\":\"\"}");

    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];

    NSString * json = [NSString stringWithFormat:@"{\"pageNo\":1,"
            "\"pageSize\":10,"
            "\"querySortType\":\"AMOUNT_DESC\","
            "\"petIds\":[],"
            "\"lastAmount\":null,"
            "\"lastRareDegree\":null,"
            "\"requestId\":%ld,"
            "\"appId\":1,\"tpl\":\"\"}", (long)timeStamp];

//    _browser.responseSerializer = [AFJSONResponseSerializer serializer];
    _browser.responseSerializer = [AFHTTPResponseSerializer serializer];
    _browser.requestSerializer = [AFJSONRequestSerializer serializer];

    _browser.responseSerializer.acceptableContentTypes = [_browser.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    [_browser POSTWithURLString:@"https://pet-chain.baidu.com/data/market/queryPetsOnSale" parameters:dictionary charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        NSLog(@"%@", html);
    }];
}


- (instancetype)init {
    self = [super init];
    if (self){
        _browser = [AFHTTPSessionManager manager];
    }
    return self;
}

@end

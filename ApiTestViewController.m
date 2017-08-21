//
//  ApiTestViewController.m
//
//  Created by WDY on 16/3/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ApiTestViewController.h"
#import "ForumApiHelper.h"
#import "NSUserDefaults+Extensions.h"

#import "CharUtils.h"
#import "CharUnicodeBlock.h"
#import "NSString+Extensions.h"




@interface ApiTestViewController () {
    NSArray *blockStarts;
    NSArray *blocks;
}

@end

@implementation ApiTestViewController

- (NSString *)currentForumHost {
    NSString *urlStr = [[NSUserDefaults standardUserDefaults] currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    id<ForumBrowserDelegate> forumApi = [ForumApiHelper forumApi];

    [forumApi listAllForums:^(BOOL isSuccess, id message) {

    }];


}





@end

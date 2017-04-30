//
//  ApiTestViewController.m
//
//  Created by WDY on 16/3/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ApiTestViewController.h"
#import "ForumBrowser.h"
#import "NSUserDefaults+Extensions.h"

@interface ApiTestViewController ()

@end

@implementation ApiTestViewController

- (NSString *)currentForumHost {
    NSString * urlStr = [[NSUserDefaults standardUserDefaults] currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (void)viewDidLoad {
    [super viewDidLoad];


//    ForumBrowser *api = [ForumBrowser browserWithForumConfig:[ForumConfig configWithForumHost:[self currentForumHost]]];
    id<ForumBrowserDelegate> api = [[[ForumBrowser alloc] init] browserWithForumConfig:[ForumConfig configWithForumHost:[self currentForumHost]]];

    [api listAllForums:^(BOOL isSuccess, id message) {

    }];

}


@end

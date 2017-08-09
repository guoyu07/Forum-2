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

//    id<ForumBrowserDelegate> forumApi = [ForumApiHelper forumApi];
//
//    [forumApi listNewThreadWithPage:1 handler:^(BOOL isSuccess, id message) {
//
//
//    }];

    NSData *data = [@"%%%%%%9999" dataForGBK];

    NSString *message = @"你好,，";
    NSRange range;
    for (int i = 0; i < message.length; i += range.length) {
        range = [message rangeOfComposedCharacterSequenceAtIndex:i];
        NSString *s = [message substringWithRange:range];

        unichar c = [s characterAtIndex:0];
        UnicodeBlock block = [CharUnicodeBlock unicodeBlockOf:c];

        NSLog(@">>>>>  %ld %@", (long)block, [CharUtils isChinese:c] ? @"CJK" : @"O÷ther");

    }

}





@end

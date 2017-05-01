//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "BaseForumApi.h"
#import "AFURLResponseSerialization.h"
#import <AFImageDownloader.h>

@implementation BaseForumApi {

}

- (id)initWithConfig:(id <ForumConfigDelegate>)configDelegate parser:(id <ForumParserDelegate>)parserDelegate {
    if (self = [super init]){

        self.browser = [AFHTTPSessionManager manager];
        self.browser.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.browser.responseSerializer.acceptableContentTypes = [self.browser.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [self.browser.requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36" forHTTPHeaderField:@"User-Agent"];

        self.configDelegate = configDelegate;
        self.parserDelegate = parserDelegate;
    }
    return self;
}

@end
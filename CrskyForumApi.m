//
//  CrskyForumApi.m
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "CrskyForumApi.h"
#import "ForumParserDelegate.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import "DeviceName.h"
#import "NSUserDefaults+Extensions.h"
#import "NSUserDefaults+Setting.h"
#import "ForumCoreDataManager.h"ƒ
#import "NSString+Extensions.h"
#import "CharUtils.h"
#import "IGHTMLDocument.h"
#import "IGHTMLDocument+QueryNode.h"

@implementation CrskyForumApi

// private
- (NSString *)buildSignature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 霏凡客户端", phoneName];
    return signature;
}

- (LoginUser *)getLoginUser {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [[NSUserDefaults standardUserDefaults] userName];
    user.userID = [[NSUserDefaults standardUserDefaults] userId];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:self.forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
}

- (BOOL)isHaveLogin:(NSString *)host {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    NSDate *date = [NSDate date];
    for (NSHTTPCookie * cookie in cookies) {
        if ([cookie.domain containsString:host] && [cookie.expiresDate compare:date] != NSOrderedAscending){
            return YES;
        }
    }
    return NO;
}

- (void)logout {
    [[NSUserDefaults standardUserDefaults] clearCookie];

    NSURL *url = self.forumConfig.forumURL;
    if (url) {
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
        for (int i = 0; i < [cookies count]; i++) {
            NSHTTPCookie *cookie = (NSHTTPCookie *) cookies[(NSUInteger) i];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (void)listAllForums:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [self.browser GETWithURLString:self.forumConfig.archive parameters:parameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString * host = self.forumConfig.forumURL.host;
            NSArray<Forum *> *parserForums = [self.forumParser parserForums:html forumHost:host];
            if (parserForums != nil && parserForums.count > 0) {
                handler(YES, parserForums);
            } else {
                handler(NO, html);
            }
        } else {
            handler(NO, html);
        }
    }];
}

- (void)fetchUserId:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    NSString * url = self.forumConfig.forumURL.absoluteString;
    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            NSString *uid = [html stringWithRegular:@"(?<=UID: )\\d+"];
            handler(isSuccess, uid);
        } else {
            handler(NO, html);
        }

    }];
}

- (void)createNewThreadWithSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page handler:(HandlerWithBool)handler {

    NSString *token = page.token;
    NSString *url = [self.forumConfig newThreadWithForumId:nil];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    self.browser.requestSerializer.stringEncoding = kCFStringEncodingGB_18030_2000;
    [self.browser POSTWithURLString:url parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {

        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicname"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicid"];
        [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];
        [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"p_type"];

        [formData appendPartWithFormData:[self buildContent:subject] name:@"atc_title"];
        [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"atc_iconid"];

        [formData appendPartWithFormData:[self buildContent:message] name:@"atc_content"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_autourl"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_usesign"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_convert"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_rvrc"];

        [formData appendPartWithFormData:[@"rvrc" dataForUTF8] name:@"atc_enhidetype"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_money"];
        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"atc_credittype"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"atc_desc1"];
//        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"att_ctype1"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_needrvrc1"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"atc_desc2"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_needrvrc2"];
        [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"step"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"pid"];
        [formData appendPartWithFormData:[@"new" dataForUTF8] name:@"action"];
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", page.forumId] dataForUTF8] name:@"fid"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"tid"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"article"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"special"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"att_special2"];
        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"att_ctype2"];

        if (images){
            for (int i = 0; i < images.count; ++i) {
                NSString *type = [self contentTypeForImageData:images[i]];
                NSString *extNmae = [type stringByReplacingOccurrencesOfString:@"image/" withString:@""];
                [formData appendPartWithFileData:images[i] name:[NSString stringWithFormat:@"attachment_%d", i] fileName:[NSString stringWithFormat:@"attachment_%d.%@", i, extNmae] mimeType:type];
            }
        } else {
            [formData appendPartWithFormData:[@"" dataForUTF8] name:@"attachment_1"];
            [formData appendPartWithFormData:[@"" dataForUTF8] name:@"attachment_2"];
        }


    } charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:html];
            if (thread.postList.count > 0) {
                handler(YES, thread);
            } else {
                handler(NO, @"未知错误");
            }
        } else {
            handler(NO, html);
        }
    }];
}

-(NSData *)buildContent:(NSString *)message{
    NSMutableData * contentData = [[NSMutableData alloc] init];
    NSMutableString * eng = [NSMutableString string];
    NSMutableString * chn = [NSMutableString string];

    BOOL isEng = YES;

    NSRange range;
    for (int i = 0; i < message.length; i += range.length) {
        range = [message rangeOfComposedCharacterSequenceAtIndex:(NSUInteger) i];

        unichar c = [message characterAtIndex:range.location];
        if (range.length == 1){

            NSString *s = [message substringWithRange:range];
            if ([CharUtils isChinese:c]){
                if (isEng && eng.length != 0){
                    [contentData appendData:[eng dataForUTF8]];
                    eng = [NSMutableString string];
                }
                [chn appendString:s];
                isEng = NO;

            } else {
                if (!isEng && chn.length != 0){
                    [contentData appendData:[chn dataForGBK]];
                    chn = [NSMutableString string];
                }
                [eng appendString:s];
                isEng = YES;
            }
        } else {
            // 非法字符忽略
        }
    }

    if (eng.length != 0){
        [contentData appendData:[eng dataForUTF8]];
    }

    if (chn.length != 0){
        [contentData appendData:[chn dataForGBK]];
    }
    return [contentData copy];
}

- (void)quickReplyPostWithMessage:(NSString *)message toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {

    int threadId = threadPage.threadID;
    NSString *token = threadPage.securityToken;
    NSString *url = [self.forumConfig replyWithThreadId:threadId forForumId:-1 replyPostId:-1];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }

    NSData * contentData = [self buildContent:message];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    self.browser.requestSerializer.stringEncoding = kCFStringEncodingGB_18030_2000;
    [self.browser POSTWithURLString:url parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {

        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_usesign"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_convert"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_money"];
        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"atc_credittype"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_rvrc"];
        [formData appendPartWithFormData:[self buildContent:threadPage.quickReplyTitle] name:@"atc_title"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_autourl"];
        [formData appendPartWithFormData:contentData name:@"atc_content"];
        [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"step"];
        [formData appendPartWithFormData:[@"reply" dataForUTF8] name:@"action"];
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", threadPage.forumId] dataForUTF8] name:@"fid"];
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", threadId] dataForUTF8] name:@"tid"];
        [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"atc_desc1"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"attachment_1"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"att_special1"];
        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"att_ctype1"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_needrvrc1"];

    } charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:html];
            if (thread.postList.count > 0) {
                handler(YES, thread);
            } else {
                handler(NO, @"未知错误");
            }
        } else {
            handler(NO, html);
        }
    }];
}

- (void)seniorReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {

    int threadId = threadPage.threadID;
    NSString *token = threadPage.securityToken;
    NSString *url = [self.forumConfig replyWithThreadId:threadId forForumId:-1 replyPostId:-1];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }

    NSData * contentData = [self buildContent:message];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    self.browser.requestSerializer.stringEncoding = kCFStringEncodingGB_18030_2000;
    [self.browser POSTWithURLString:url parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {

        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicname"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicid"];
        [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];
        [formData appendPartWithFormData:[@"RE:" dataForUTF8] name:@"atc_title"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_iconid"];
        [formData appendPartWithFormData:contentData name:@"atc_content"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_autourl"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_usesign"];
        [formData appendPartWithFormData:[@"1" dataForUTF8] name:@"atc_convert"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_rvrc"];
        [formData appendPartWithFormData:[@"rvrc" dataForUTF8] name:@"atc_enhidetype"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_money"];
        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"atc_credittype"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"atc_desc1"];

        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"att_ctype1"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_needrvrc1"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"atc_desc2"];

        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"atc_needrvrc2"];
        [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"step"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"pid"];
        [formData appendPartWithFormData:[@"reply" dataForUTF8] name:@"action"];
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", threadPage.forumId] dataForUTF8] name:@"fid"];
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", threadId] dataForUTF8] name:@"tid"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"article"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"special"];
        [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"att_special2"];
        [formData appendPartWithFormData:[@"money" dataForUTF8] name:@"att_ctype2"];

        if (images){
            for (int i = 0; i < images.count; ++i) {
                NSString *type = [self contentTypeForImageData:images[i]];
                NSString *extNmae = [type stringByReplacingOccurrencesOfString:@"image/" withString:@""];
                [formData appendPartWithFileData:images[i] name:[NSString stringWithFormat:@"attachment_%d", i] fileName:[NSString stringWithFormat:@"attachment_%d.%@", i, extNmae] mimeType:type];
            }
        } else {
            [formData appendPartWithFormData:[@"" dataForUTF8] name:@"attachment_1"];
            [formData appendPartWithFormData:[@"" dataForUTF8] name:@"attachment_2"];
        }


    } charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:html];
            if (thread.postList.count > 0) {
                handler(YES, thread);
            } else {
                handler(NO, @"未知错误");
            }
        } else {
            handler(NO, html);
        }
    }];

}

// private
- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {

    NSLog(@"searchWithKeyWord-->\t%@",  keyWord);

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"2" forKey:@"step"];

    [parameters setValue:@"OR" forKey:@"method"];

    if (type == 0){         // search tile
        [parameters setValue:@"0" forKey:@"sch_area"];
        [parameters setValue:keyWord forKey:@"keyword"];
        [parameters setValue:@"" forKey:@"pwuser"];
    } else if(type == 1){   // search content
        [parameters setValue:@"2" forKey:@"sch_area"];
        [parameters setValue:keyWord forKey:@"keyword"];
        [parameters setValue:@"" forKey:@"pwuser"];
    } else{                 //  search user
        [parameters setValue:@"0" forKey:@"sch_area"];
        [parameters setValue:@"" forKey:@"keyword"];
        [parameters setValue:keyWord forKey:@"pwuser"];
    }

    [parameters setValue:@"1" forKey:@"ttable"];
    [parameters setValue:@"0" forKey:@"ptable"];

    [parameters setValue:@"all" forKey:@"f_fid"];
    [parameters setValue:@"all" forKey:@"sch_time"];
    [parameters setValue:@"lastpost" forKey:@"orderway"];
    [parameters setValue:@"DESC" forKey:@"asc"];

    self.browser.requestSerializer.stringEncoding = kCFStringEncodingGB_18030_2000;
    [self.browser POSTWithURLString:self.forumConfig.search parameters:parameters charset:GBK requestCallback:^(BOOL searchSuccess, NSString *searchResult) {
        ViewSearchForumPage *page = [self.forumParser parseSearchPageFromHtml:searchResult];

        if (page != nil && page.dataList != nil && page.dataList.count > 0) {
            handler(YES, page);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)showPrivateMessageContentWithId:(int)pmId withType:(int)type handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"winds" forKey:@"skinco"];

    NSString * url = [self.forumConfig privateShowWithMessageId:pmId withType:type];
    [self.browser GETWithURLString:url parameters:parameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewMessagePage *content = [self.forumParser parsePrivateMessageContent:html avatarBase:self.forumConfig.avatarBase noavatar:self.forumConfig.avatarNo];
            if (![content.pmUserInfo.userID isEqualToString:@"-1"]){
                [self getAvatarWithUserId:content.pmUserInfo.userID handler:^(BOOL success, id message) {
                    content.pmUserInfo.userAvatar = message;
                    handler(YES, content);
                }];
            } else{
                content.pmUserInfo.userAvatar = self.forumConfig.avatarNo;
                handler(YES, content);
            }
        } else {
            handler(NO, html);
        }
    }];
}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:self.forumConfig.privateNewPre parameters:parameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];

            [self.browser POSTWithURLString:self.forumConfig.privateReplyWithMessage parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                [formData appendPartWithFormData:[@"write" dataForUTF8]  name:@"action"];
                [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"step"];
                [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];
                LoginUser *user = [self getLoginUser];
                [formData appendPartWithFormData:[self buildContent:user.userName] name:@"pwuser"];
                [formData appendPartWithFormData:[self buildContent:title] name:@"msg_title"];
                [formData appendPartWithFormData:[@"" dataForUTF8] name:@"font"];
                [formData appendPartWithFormData:[@"" dataForUTF8] name:@"size"];
                [formData appendPartWithFormData:[@"" dataForUTF8] name:@"color"];
                [formData appendPartWithFormData:[self buildContent:message] name:@"atc_content"];
                [formData appendPartWithFormData:[@"Y" dataForUTF8] name:@"ifsave"];
            } charset:GBK requestCallback:^(BOOL success, NSString *result) {
                if (success) {
                    handler(YES, @"");
                } else {
                    handler(NO, result);
                }
            }];
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)replyPrivateMessage:(Message *)privateMessage andReplyContent:(NSString *)content handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:[self.forumConfig privateReplyWithMessageIdPre:[privateMessage.pmID intValue]] parameters:parameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];

            IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
            IGXMLNode * node = [document queryNodeWithXPath:@"//*[@id=\"atc_content\"]"];
            NSString *repContent = node.text;

            [self.browser POSTWithURLString:self.forumConfig.privateReplyWithMessage parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                [formData appendPartWithFormData:[@"write" dataForUTF8] name:@"action"];
                [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"step"];
                [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];
                [formData appendPartWithFormData:[self buildContent:privateMessage.pmAuthor] name:@"pwuser"];

                NSString *repTitle = [NSString stringWithFormat:@"Re:%@", privateMessage.pmTitle];
                [formData appendPartWithFormData:[self buildContent:repTitle] name:@"msg_title"];
                [formData appendPartWithFormData:[@"" dataForUTF8] name:@"font"];
                [formData appendPartWithFormData:[@"" dataForUTF8] name:@"size"];
                [formData appendPartWithFormData:[@"" dataForUTF8] name:@"color"];

                NSString *buildRepContent = [NSString stringWithFormat:@"%@\n%@", repContent, content];
                [formData appendPartWithFormData:[self buildContent:buildRepContent] name:@"atc_content"];
                [formData appendPartWithFormData:[@"Y" dataForUTF8] name:@"ifsave"];
            }                       charset:GBK requestCallback:^(BOOL success, NSString *result) {
                if (success) {
                    handler(YES, @"");
                } else {
                    handler(NO, result);
                }
            }];
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

    NSString *key = [self.forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];

    if (data){
        NSArray * favForumIds = [data componentsSeparatedByString:@","];
        NSLog(@"favoriteForumsWithId \t%@", favForumIds);
        if (![favForumIds containsObject:forumId]){
            NSMutableArray * array = [favForumIds mutableCopy];
            [array addObject:forumId];

            // 存到云端
            NSString * newForums = [array componentsJoinedByString:@","];
            [store setString:newForums forKey:key];
            [store synchronize];

            // 存到本地
            NSMutableArray * ids = [NSMutableArray array];
            for (NSString *fid in favForumIds){
                [ids addObject:@([fid intValue])];
            }
            [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];
        }
    } else {
        NSMutableArray * array = [NSMutableArray array];
        [array addObject:forumId];

        // 存到云端
        NSString * newForums = [array componentsJoinedByString:@","];
        [store setString:newForums forKey:key];
        [store synchronize];

        // 存到本地
        NSMutableArray * ids = [NSMutableArray array];

        [ids addObject:@([forumId intValue])];
        [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];
    }

    handler(YES, @"SUCCESS");

}

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *key = [self.forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];
    NSArray * favForumIds = [data componentsSeparatedByString:@","];
    NSLog(@"favoriteForumsWithId \t%@", favForumIds);
    if ([favForumIds containsObject:forumId]){
        NSMutableArray * array = [favForumIds mutableCopy];
        [array removeObject:forumId];

        // 存到云端
        NSString * newForums = [array componentsJoinedByString:@","];
        [store setString:newForums forKey:key];
        [store synchronize];

        // 存到本地
        NSMutableArray * ids = [NSMutableArray array];
        for (NSString *fid in favForumIds){
            [ids addObject:@([fid intValue])];
        }
        [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];
    }

    handler(YES, @"SUCCESS");
}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    NSString *preUrl = [self.forumConfig favThreadWithIdPre:threadPostId];
    [self.browser GETWithURLString:preUrl parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else {
            NSString *token = [self.forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"verify"];
            NSString *fav = [self.forumConfig favThreadWithId:threadPostId];
            [self.browser GETWithURLString:fav parameters:parameters charset:GBK requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];
        }
    }];

}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:@"http://bbs.crsky.com/u.php?action=favor" parameters:parameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];

            [self.browser POSTWithURLString:[self.forumConfig unFavorThreadWithId:threadPostId] parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];

                [formData appendPartWithFormData:[threadPostId dataForUTF8] name:@"selid[]"];
                [formData appendPartWithFormData:[@"0" dataForUTF8] name:@"type"];
                [formData appendPartWithFormData:[@"clear" dataForUTF8] name:@"job"];
            }   charset:GBK requestCallback:^(BOOL success, NSString *result) {
                if (success) {
                    handler(YES, @"");
                } else {
                    handler(NO, result);
                }
            }];
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:[self.forumConfig privateWithType:type withPage:page] parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parsePrivateMessageFromHtml:html forType:type];
            handler(YES, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listFavoriteForums:(HandlerWithBool)handler {

    NSString *key = [self.forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];

    NSString * data = [store stringForKey:key];
    NSArray * favForumIds = [data componentsSeparatedByString:@","];
    NSMutableArray * ids = [NSMutableArray array];
    for (NSString *forumId in favForumIds){
        [ids addObject:@([forumId intValue])];
    }
    [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];

    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    NSArray *forms = [[manager selectFavForums:ids] mutableCopy];

    handler(YES, forms);
}

- (void)listFavoriteThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig listFavorThreads:userId withPage:page];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseFavorThreadListFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    NSDate *date = [NSDate date];
    NSInteger timeStamp = (NSInteger) [date timeIntervalSince1970];

    NSInteger searchId = [userDefault integerForKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
    NSInteger lastTimeStamp = [userDefault integerForKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];

    // 参数
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    long spaceTime = timeStamp - lastTimeStamp;
    if (searchId == 0 || spaceTime > 60 * 10) {

        [self.browser GETWithURLString:[self.forumConfig searchNewThread:page] parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSUInteger newThreadPostSearchId = (NSUInteger) [[self.forumParser parseListMyThreadSearchId:html] integerValue];
                [userDefault setInteger:timeStamp forKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];
                [userDefault setInteger:newThreadPostSearchId forKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
            }
            if (isSuccess) {
                ViewSearchForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchIdStr = [NSString stringWithFormat:@"%ld", (long) searchId];
        NSString *url = [self.forumConfig searchWithSearchId:searchIdStr withPage:page];

        [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    LoginUser *user = [self getLoginUser];
    NSString *url = [self.forumConfig listUserThreads:user.userID withPage:page];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseListMyAllThreadsFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    NSString * uid = [NSString stringWithFormat:@"%d", userId];

    NSString *url = [self.forumConfig listUserThreads:uid withPage:page];
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseListMyAllThreadsFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    NSString * url = [self.forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];
    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            ViewThreadPage *detail = [self.forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
        }

    }];
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {

}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    NSString*url = [self.forumConfig forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page];
    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    if ([userId isEqualToString:@"-1"]){
        handler(YES, self.forumConfig.avatarNo);
        return;
    }
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [self.forumParser parseUserAvatar:html userId:userId];
        if (!avatar){
            avatar = self.forumConfig.avatarNo;
        }
        NSLog(@"getAvatarWithUserId \t%@", avatar);
        handler(isSuccess, avatar);
    }];
}

- (void)listSearchResultWithSearchId:(NSString *)searchid keyWord:(NSString *)keyWord andPage:(int)page handler:(HandlerWithBool)handler {

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];
    [defparameters setValue:keyWord forKey:@"keyword"];


    NSString *searchedUrl = [self.forumConfig searchWithSearchId:searchid withPage:page];
    [self.browser GETWithURLString:searchedUrl parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            ViewSearchForumPage *viewSearchForumPage = [self.forumParser parseSearchPageFromHtml:html];

            if (viewSearchForumPage != nil && viewSearchForumPage.dataList != nil && viewSearchForumPage.dataList.count > 0) {
                handler(YES, viewSearchForumPage);
            } else {
                handler(NO, @"未知错误");
            }

        } else {
            handler(NO, html);
        }
    }];
}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"winds" forKey:@"skinco"];

    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:defparameters charset:GBK requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [self.forumParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    handler(YES,@"");
}

- (id <ForumConfigDelegate>)currentConfigDelegate {
    return self.forumConfig;
}


@end

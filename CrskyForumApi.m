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
#import "NSUserDefaults+Extensions.h"
#import "NSUserDefaults+Setting.h"
#import "ForumCoreDataManager.h"ƒ
#import "NSString+Extensions.h"
#import "CharUtils.h"
#import "IGHTMLDocument.h"
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "CrskyForumConfig.h"
#import "CrskyForumHtmlParser.h"
#import "LocalForumApi.h"

@implementation CrskyForumApi{
    id <ForumConfigDelegate> forumConfig;
    id <ForumParserDelegate> forumParser;
}


- (instancetype)init {
    self = [super init];
    if (self){
        forumConfig = [[CrskyForumConfig alloc] init];
        forumParser = [[CrskyForumHtmlParser alloc]init];
    }
    return self;
}

- (void)GET:(NSString *)url parameters:(NSDictionary *)parameters requestCallback:(RequestCallback)callback{
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"2" forKey:@"styleid"];
    [defparameters setValue:@"1" forKey:@"langid"];

    if (parameters){
        [defparameters addEntriesFromDictionary:parameters];
    }

    [self.browser GETWithURLString:url parameters:defparameters charset:GBK requestCallback:callback];
}

- (void)GET:(NSString *)url requestCallback:(RequestCallback)callback{
    [self GET:url parameters:nil requestCallback:callback];
}

- (void)listAllForums:(HandlerWithBool)handler {
    NSString * url = forumConfig.archive;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString * host = forumConfig.forumURL.host;
            NSArray<Forum *> *parserForums = [forumParser parserForums:html forumHost:host];
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
    NSString * url = forumConfig.forumURL.absoluteString;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *uid = [html stringWithRegular:@"(?<=UID: )\\d+"];
            handler(isSuccess, uid);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listThreadCategory:(NSString *)fid handler:(HandlerWithBool)handler {

    NSString * url = [NSString stringWithFormat:@"http://bbs.crsky.com/post.php?fid=%@", fid];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

            IGXMLNode * node = [document queryNodeWithClassName:@"fr gray"];
            IGXMLNodeSet * cats = [node childAt:0].children;

            NSMutableArray * array = [NSMutableArray array];

            for (IGXMLNode * c in cats){
                NSString * value = [c attribute:@"value"];
                if (![value isEqualToString:@""]){
                    [array addObject:c.text.trim];
                }

            }

            handler(isSuccess, array);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title
                         andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page handler:(HandlerWithBool)handler {
    NSString *token = page.token;
    NSString *url = [forumConfig newThreadWithForumId:nil];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[forumConfig signature]];
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    self.browser.requestSerializer.stringEncoding = kCFStringEncodingGB_18030_2000;
    [self.browser POSTWithURLString:url parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {

        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicname"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicid"];
        [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];

        NSString *indexStr = [NSString stringWithFormat:@"%d", index];
        [formData appendPartWithFormData:[indexStr dataForUTF8] name:@"p_type"];

        [formData appendPartWithFormData:[self buildContent:title] name:@"atc_title"];
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

            ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:html];
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
    NSString *url = [forumConfig replyWithThreadId:threadId forForumId:-1 replyPostId:-1];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[forumConfig signature]];
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

            ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:html];
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
    NSString *url = [forumConfig replyWithThreadId:threadId forForumId:-1 replyPostId:-1];

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[forumConfig signature]];
    }

    NSData * contentData = [self buildContent:message];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    self.browser.requestSerializer.stringEncoding = kCFStringEncodingGB_18030_2000;
    [self.browser POSTWithURLString:url parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {

        NSString * reTitle = [@"Re:" stringByAppendingString:threadPage.threadTitle];

        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicname"];
        [formData appendPartWithFormData:[@"" dataForUTF8] name:@"magicid"];
        [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];
        [formData appendPartWithFormData:[self buildContent:reTitle] name:@"atc_title"];
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

            ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:html];
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
    [self.browser POSTWithURLString:forumConfig.search parameters:parameters charset:GBK requestCallback:^(BOOL searchSuccess, NSString *searchResult) {
        ViewSearchForumPage *page = [forumParser parseSearchPageFromHtml:searchResult];

        if (page != nil && page.dataList != nil && page.dataList.count > 0) {
            handler(YES, page);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)showPrivateMessageContentWithId:(int)pmId withType:(int)type handler:(HandlerWithBool)handler {

    NSString * url = [forumConfig privateShowWithMessageId:pmId withType:type];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewMessagePage *content = [forumParser parsePrivateMessageContent:html avatarBase:forumConfig.avatarBase noavatar:forumConfig.avatarNo];
            if (![content.pmUserInfo.userID isEqualToString:@"-1"]){
                [self getAvatarWithUserId:content.pmUserInfo.userID handler:^(BOOL success, id message) {
                    content.pmUserInfo.userAvatar = message;
                    handler(YES, content);
                }];
            } else{
                content.pmUserInfo.userAvatar = forumConfig.avatarNo;
                handler(YES, content);
            }
        } else {
            handler(NO, html);
        }
    }];
}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSString *url =forumConfig.privateNewPre;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            [self.browser POSTWithURLString:forumConfig.privateReplyWithMessage parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
                [formData appendPartWithFormData:[@"write" dataForUTF8]  name:@"action"];
                [formData appendPartWithFormData:[@"2" dataForUTF8] name:@"step"];
                [formData appendPartWithFormData:[token dataForUTF8] name:@"verify"];
                LoginUser *user = [[[LocalForumApi alloc] init] getLoginUser:(forumConfig.forumURL.host)];
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
    NSString *url = [forumConfig privateReplyWithMessageIdPre:[privateMessage.pmID intValue]];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
            IGXMLNode * node = [document queryNodeWithXPath:@"//*[@id=\"atc_content\"]"];
            NSString *repContent = node.text;

            [self.browser POSTWithURLString:forumConfig.privateReplyWithMessage parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
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

    NSString *key = [forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

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
    NSString *key = [forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

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

    NSString *preUrl = [forumConfig favThreadWithIdPre:threadPostId];
    [self GET:preUrl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else {
            NSString *token = [forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"verify"];
            NSString *fav = [forumConfig favThreadWithId:threadPostId];
            [self.browser GETWithURLString:fav parameters:parameters charset:GBK requestCallback:^(BOOL success, NSString *result) {
                handler(success, result);
            }];
        }
    }];

}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

    NSString *url = @"http://bbs.crsky.com/u.php?action=favor";
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            [self.browser POSTWithURLString:[forumConfig unFavorThreadWithId:threadPostId] parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
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
    NSString *url = [forumConfig privateWithType:type withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parsePrivateMessageFromHtml:html forType:type];
            handler(YES, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listFavoriteForums:(HandlerWithBool)handler {

    NSString *key = [forumConfig.forumURL.host stringByAppendingString:@"-favForums"];

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
    NSString *url = [forumConfig listFavorThreads:userId withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parseFavorThreadListFromHtml:html];
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

    NSInteger searchId = [userDefault integerForKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
    NSInteger lastTimeStamp = [userDefault integerForKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];

    long spaceTime = timeStamp - lastTimeStamp;
    if (searchId == 0 || spaceTime > 60 * 10) {

        NSString *url = [forumConfig searchNewThread:page];
        [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSUInteger newThreadPostSearchId = (NSUInteger) [[forumParser parseListMyThreadSearchId:html] integerValue];
                [userDefault setInteger:timeStamp forKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];
                [userDefault setInteger:newThreadPostSearchId forKey:[forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
            }
            if (isSuccess) {
                ViewSearchForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchIdStr = [NSString stringWithFormat:@"%ld", (long) searchId];
        NSString *url = [forumConfig searchWithSearchId:searchIdStr withPage:page];

        [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else {
                handler(NO, html);
            }
        }];
    }
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    LoginUser *user = [[[LocalForumApi alloc] init] getLoginUser:(forumConfig.forumURL.host)];
    NSString *url = [forumConfig listUserThreads:user.userID withPage:page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parseListMyAllThreadsFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    NSString * uid = [NSString stringWithFormat:@"%d", userId];

    NSString *url = [forumConfig listUserThreads:uid withPage:page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parseListMyAllThreadsFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {
    NSString * url = [forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewThreadPage *detail = [forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {

    NSString *url = [forumConfig forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [forumParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    if ([userId isEqualToString:@"-1"]){
        handler(YES, forumConfig.avatarNo);
        return;
    }

    NSString *url = [forumConfig memberWithUserId:userId];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [forumParser parseUserAvatar:html userId:userId];
        if (!avatar){
            avatar = forumConfig.avatarNo;
        }
        NSLog(@"getAvatarWithUserId \t%@", avatar);
        handler(isSuccess, avatar);
    }];
}

- (void)listSearchResultWithSearchId:(NSString *)searchid keyWord:(NSString *)keyWord andPage:(int)page handler:(HandlerWithBool)handler {

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:keyWord forKey:@"keyword"];
    NSString *searchedUrl = [forumConfig searchWithSearchId:searchid withPage:page];

    [self GET:searchedUrl parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {

            ViewSearchForumPage *viewSearchForumPage = [forumParser parseSearchPageFromHtml:html];

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
    NSString *url = [forumConfig memberWithUserId:userId];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [forumParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    handler(YES,@"");
}

@end

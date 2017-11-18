//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "CHHForumApi.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import "ForumParserDelegate.h"
#import "NSUserDefaults+Setting.h"

#import "IGHTMLDocument+QueryNode.h"
#import "CHHForumConfig.h"
#import "CHHForumHtmlParser.h"


@implementation CHHForumApi {

    id <ForumConfigDelegate> forumConfig;
    id <ForumParserDelegate> forumParser;
}

- (instancetype)init {
    self = [super init];
    if (self){
        forumConfig = [[CHHForumConfig alloc] init];
        forumParser = [[CHHForumHtmlParser alloc]init];
    }
    return self;
}

- (void)GET:(NSString *)url parameters:(NSDictionary *)parameters requestCallback:(RequestCallback)callback{
    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];

    if (parameters){
        [defparameters addEntriesFromDictionary:parameters];
    }

    [self.browser GETWithURLString:url parameters:defparameters charset:UTF_8 requestCallback:callback];
}

- (void)GET:(NSString *)url requestCallback:(RequestCallback)callback{
    [self GET:url parameters:nil requestCallback:callback];
}

- (void)listAllForums:(HandlerWithBool)handler {
    NSString *url = forumConfig.archive;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSArray<Forum *> *parserForums = [forumParser parserForums:html forumHost:forumConfig.forumURL.host];
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

- (void)listThreadCategory:(NSString *)fid handler:(HandlerWithBool)handler {
    NSArray *categorys = @[@"【分享】", @"【推荐】", @"【求助】", @"【注意】", @"【ＣＸ】", @"【高兴】", @"【难过】", @"【转帖】", @"【原创】", @"【讨论】"];
    handler(YES,categorys);
}

- (void)seniorReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {
    NSString *msg = message;

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        msg = [message stringByAppendingString:[forumConfig signature]];
    }

    int replyPostId = [postId intValue];
    NSString *token = threadPage.securityToken;
    int threadId = threadPage.threadID;
    int forumId = threadPage.forumId;

    if (replyPostId != -1){     // 表示回复的某一个楼层

        NSString *preReplyUrl = [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&extra=page%%3D1&tid=%d&repquote=%d", forumId, threadId, replyPostId];

        [self GET:preReplyUrl requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSString *formHash = nil;
                NSString *posttime = nil;
                NSString *wysiwyg = nil;
                NSString *noticeauthor = nil;
                NSString *noticetrimstr = nil;
                NSString *noticeauthormsg = nil;
                NSString *reppid = nil;
                NSString *reppost = nil;

                IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithXMLString:html error:nil];

                IGXMLNode *paramNode = [document queryNodeWithXPath:@"//*[@id='ct']"];
                for (IGXMLNode *node  in paramNode.children) {
                    NSString * nodeName = [node attribute:@"name"];

                    if ([nodeName isEqualToString:@"formhash"]) {
                        formHash = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"posttime"]) {
                        posttime = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"wysiwyg"]) {
                        wysiwyg = [node attribute:@"value"];
                    } else if([nodeName isEqualToString:@"noticeauthor"]){
                        noticeauthor = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"noticetrimstr"]){
                        noticetrimstr = [node attribute:@"value"];
                    } else if ([nodeName isEqualToString:@"noticeauthormsg"]){
                        noticeauthormsg = [node attribute:@"value"];
                    }else if ([nodeName isEqualToString:@"reppid"]){
                        reppid = [node attribute:@"value"];
                    }else if ([nodeName isEqualToString:@"reppost"]){
                        reppost = [node attribute:@"value"];
                    }

                    else {
                        continue;
                    }
                }

                // 开始回复
                NSString *url = [forumConfig replyWithThreadId:threadId forForumId:forumId replyPostId:replyPostId];

                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                [parameters setValue:token forKey:@"formhash"];

                [parameters setValue:posttime forKey:@"posttime"];
                [parameters setValue:@"1" forKey:@"wysiwyg"];
                [parameters setValue:noticeauthor forKey:@"noticeauthor"];
                [parameters setValue:noticetrimstr forKey:@"noticetrimstr"];
                [parameters setValue:noticeauthormsg forKey:@"noticeauthormsg"];

                [parameters setValue:reppid forKey:@"reppid"];
                [parameters setValue:reppost forKey:@"reppost"];
                [parameters setValue:@"" forKey:@"subject"];
                [parameters setValue:msg forKey:@"message"];
                [parameters setValue:@"" forKey:@"save"];

                [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL repsuccess, NSString *repHtml) {
                    ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:repHtml];
                    if (thread.postList.count > 0) {
                        handler(YES, thread);
                    } else {
                        handler(NO, @"未知错误");
                    }
                }];

            } else {
                handler(NO, html);
            }
        }];

    } else {
        NSString *url = [forumConfig replyWithThreadId:threadId forForumId:forumId replyPostId:replyPostId];

        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:msg forKey:@"message"];
        [parameters setValue:token forKey:@"formhash"];
        long time = (long) [[NSDate date] timeIntervalSince1970];
        [parameters setValue:[NSString stringWithFormat:@"%li", time] forKey:@"posttime"];
        [parameters setValue:@"" forKey:@"wysiwyg"];

        [parameters setValue:@"" forKey:@"noticeauthor"];
        [parameters setValue:@"" forKey:@"noticetrimstr"];

        [parameters setValue:@"" forKey:@"noticeauthormsg"];
        [parameters setValue:@"" forKey:@"subject"];
        [parameters setValue:@"0" forKey:@"save"];

        [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
            ViewThreadPage *thread = [forumParser parseShowThreadWithHtml:html];
            if (thread.postList.count > 0) {
                handler(YES, thread);
            } else {
                handler(NO, @"未知错误");
            }
        }];
    }
}

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *rurl = @"https://www.chiphell.com/home.php?mod=space&do=favorite&view=me";

    [self GET:rurl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"formhash"];
            [parameters setValue:@"true" forKey:@"delfavorite"];
            [parameters setValue:@"" forKey:@"favorite[]"];

            NSString *url = [forumConfig unFavorThreadWithId:nil];
            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
            }];
        } else {
            handler(NO, nil);
        }
    }];
}


- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

    NSString *rurl = @"https://www.chiphell.com/home.php?mod=space&do=favorite&view=me";
    [self GET:rurl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"formhash"];
            [parameters setValue:@"true" forKey:@"delfavorite"];
            [parameters setValue:@"" forKey:@"favorite[]"];

            NSString *url = [forumConfig unFavorThreadWithId:threadPostId];
            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
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

- (BOOL)openUrlByClient:(ForumWebViewController *)controller request:(NSURLRequest *)request {
    return NO;
}

- (void)listFavoriteForums:(HandlerWithBool)handler {
    NSMutableArray * result = [NSMutableArray array];

    __block int page = 1;
    [self listFavoriteForums:page handler:^(BOOL isSuccess, id m) {
        if (isSuccess){
            NSMutableArray<Forum *> *favForms = [forumParser parseFavForumFromHtml:m];
            [result addObjectsFromArray:favForms];
            PageNumber * pageNumber = [forumParser parserPageNumber:m];

            if (pageNumber.totalPageNumber > page){
                for (int i = page + 1; i <= pageNumber.totalPageNumber; i++) {
                    [self listFavoriteForums:i handler:^(BOOL success, id html) {
                        if (success){
                            NSMutableArray<Forum *> *forums = [forumParser parseFavForumFromHtml:html];
                            [result addObjectsFromArray:forums];
                            page = i;
                            if (page >= pageNumber.totalPageNumber){

                                handler(YES, result);
                            }
                        } else{
                            handler(NO, html);
                        }
                    }];
                }
            } else{
                handler(YES, result);
            }
        } else{
            handler(NO, m);
        }

        
    }];
}

// private
- (void)listFavoriteForums:(int ) page handler:(HandlerWithBool)handler {
    NSString * baseUrl = forumConfig.favoriteForums;
    NSString * favForumsURL = [NSString stringWithFormat:@"%@&page=%d",baseUrl,page];

    [self GET:favForumsURL requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
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

    NSString *url = [forumConfig searchNewThread:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewSearchForumPage *searchForumPage = [forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, searchForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = @"https://www.chiphell.com/forum.php?mod=guide&view=my";
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, sarchPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

    NSString *baseUrl = [forumConfig searchThreadWithUserId:[NSString stringWithFormat:@"%d", userId]];

    NSString * url = [baseUrl stringByAppendingFormat:@"%d", page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *sarchPage = [forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, sarchPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {

    //https://www.chiphell.com/thread-1732141-2-1.html

    NSString *url = [forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];

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

    NSString *url = [forumConfig memberWithUserId:userId];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [forumParser parseUserAvatar:html userId:userId];
        if (avatar) {
            avatar = [forumConfig.avatarBase stringByAppendingString:avatar];
        } else {
            avatar = forumConfig.avatarNo;
        }
        handler(isSuccess, avatar);
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

- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title
                         andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page handler:(HandlerWithBool)handler {

}

- (void)quoteReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {
//    NSString *quoteUrl = [forumConfig quoteReply:threadPage.forumId threadId:threadPage.threadID postId:[postId intValue]];
//    [self GET:quoteUrl requestCallback:^(BOOL isSuccess, NSString *html) {
//        if (isSuccess) {
//
//            NSString * quoteString = [forumParser parseQuote:html];
//
//            NSString * replyContent = [NSString stringWithFormat:@"%@ %@", quoteString, message];
//            [self seniorReplyPostWithMessage:replyContent withImages:images toPostId:postId thread:threadPage handler:handler];
//
//        } else {
//            handler(NO, html);
//        }
//    }];
    [self seniorReplyPostWithMessage:message withImages:images toPostId:postId thread:threadPage handler:handler];
}


- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {

}

- (void)showPrivateMessageContentWithId:(int)pmId withType:(int)type handler:(HandlerWithBool)handler {

}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)replyPrivateMessage:(Message *)privateMessage andReplyContent:(NSString *)content handler:(HandlerWithBool)handler {

}

- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)deletePrivateMessage:(Message *)privateMessage withType:(int)type handler:(HandlerWithBool)handler {

}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {

}

- (void)listSearchResultWithSearchId:(NSString *)searchid keyWord:(NSString *)keyWord andPage:(int)page handler:(HandlerWithBool)handler {
}

@end

//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "CHHForumApi.h"
#import "NSUserDefaults+Extensions.h"
#import "DeviceName.h"
#import "NSString+Extensions.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import "ForumParserDelegate.h"
#import "NSUserDefaults+Setting.h"

#import "IGHTMLDocument+QueryNode.h"
#import "CHHForumConfig.h"
#import "CHHForumHtmlParser.h"


@implementation CHHForumApi {

}

- (instancetype)init {
    self = [super init];
    if (self){
        self.forumConfig = [[CHHForumConfig alloc] init];
        self.forumParser = [[CHHForumHtmlParser alloc]init];
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
    NSString *url = self.forumConfig.archive;
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSArray<Forum *> *parserForums = [self.forumParser parserForums:html forumHost:self.forumConfig.forumURL.host];
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


- (void)createNewThreadWithCategory:(NSString *)category categoryIndex:(int)index withTitle:(NSString *)title
                         andMessage:(NSString *)message withImages:(NSArray *)images inPage:(ViewForumPage *)page handler:(HandlerWithBool)handler {


}

- (void)quickReplyPostWithMessage:(NSString *)message toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {

}

- (void)seniorReplyPostWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage handler:(HandlerWithBool)handler {
    NSString *msg = message;

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        msg = [message stringByAppendingString:[self.forumConfig signature]];
    }

    int replyPostId = [postId intValue];
    NSString *token = threadPage.securityToken;
    int threadId = threadPage.threadID;
    int forumId = threadPage.forumId;

    if (replyPostId == -1){     // 表示回复的某一个楼层
        NSString *preReplyUrl = [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&tid=%d&reppost=%d&extra=page%%3D1&page=1&infloat=yes&handlekey=reply&inajax=1&ajaxtarget=fwin_content_reply", forumId, threadId, replyPostId];

        [self GET:preReplyUrl requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                NSString *formHash = nil;
                NSString *noticeAuthor = nil;
                NSString *noticeAuthorMsg = nil;
                int repPid = replyPostId;
                int repPost = replyPostId;

                IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithXMLString:html error:nil];
                IGXMLNode *paramNode = [document queryNodeWithXPath:@"//*[@id=\"floatlayout_reply\"]/div"];
                for (IGXMLNode *node  in paramNode.children) {
                    if ([[node attribute:@"name"] isEqualToString:@"formhash"]) {
                        formHash = [node attribute:@"value"];
                    } else if ([[node attribute:@"name"] isEqualToString:@"noticeauthor"]) {
                        noticeAuthor = [node attribute:@"value"];
                    } else if ([[node attribute:@"name"] isEqualToString:@"noticeauthormsg"]) {
                        noticeAuthorMsg = [node attribute:@"value"];
                    } else {
                        continue;
                    }
                }

                // 开始回复
                NSString *url = [self.forumConfig replyWithThreadId:threadId forForumId:forumId replyPostId:replyPostId];

                NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
                [parameters setValue:token forKey:@"formhash"];
                [parameters setValue:@"reply" forKey:@"handlekey"];
                [parameters setValue:noticeAuthor forKey:@"noticeauthor"];
                [parameters setValue:@"" forKey:@"noticetrimstr"];
                [parameters setValue:noticeAuthorMsg forKey:@"noticeauthormsg"];
                [parameters setValue:@"0" forKey:@"usesig"];
                [parameters setValue:[NSString stringWithFormat:@"%d", repPid] forKey:@"reppid"];
                [parameters setValue:[NSString stringWithFormat:@"%d", repPost] forKey:@"reppost"];
                [parameters setValue:@"" forKey:@"subject"];
                [parameters setValue:msg forKey:@"message"];

                [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL repsuccess, NSString *repHtml) {
                    ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:html];
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
        NSString *url = [self.forumConfig replyWithThreadId:threadId forForumId:forumId replyPostId:replyPostId];

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
            ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:html];
            if (thread.postList.count > 0) {
                handler(YES, thread);
            } else {
                handler(NO, @"未知错误");
            }
        }];
    }
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

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *rurl = @"https://www.chiphell.com/home.php?mod=space&do=favorite&view=me";

    [self GET:rurl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"formhash"];
            [parameters setValue:@"true" forKey:@"delfavorite"];
            [parameters setValue:@"" forKey:@"favorite[]"];

            NSString *url = [self.forumConfig unFavorThreadWithId:nil];
            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
            }];
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

    NSString *rurl = @"https://www.chiphell.com/home.php?mod=space&do=favorite&view=me";
    [self GET:rurl requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:token forKey:@"formhash"];
            [parameters setValue:@"true" forKey:@"delfavorite"];
            [parameters setValue:@"" forKey:@"favorite[]"];

            NSString *url = [self.forumConfig unFavorThreadWithId:threadPostId];
            [self.browser POSTWithURLString:url parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *string) {
                handler(success, string);
            }];
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {

    NSString *url = [self.forumConfig privateWithType:type withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parsePrivateMessageFromHtml:html forType:type];
            handler(YES, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listFavoriteForums:(HandlerWithBool)handler {
    NSMutableArray * result = [NSMutableArray array];

    __block int page = 1;
    [self listFavoriteForums:page handler:^(BOOL isSuccess, id m) {
        if (isSuccess){
            NSMutableArray<Forum *> *favForms = [self.forumParser parseFavForumFromHtml:m];
            [result addObjectsFromArray:favForms];
            PageNumber * pageNumber = [self.forumParser parserPageNumber:m];

            if (pageNumber.totalPageNumber > page){
                for (int i = page + 1; i <= pageNumber.totalPageNumber; i++) {
                    [self listFavoriteForums:i handler:^(BOOL success, id html) {
                        if (success){
                            NSMutableArray<Forum *> *forums = [self.forumParser parseFavForumFromHtml:html];
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
    NSString * baseUrl = self.forumConfig.favoriteForums;
    NSString * favForumsURL = [NSString stringWithFormat:@"%@&page=%d",baseUrl,page];

    [self GET:favForumsURL requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)listFavoriteThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig listFavorThreads:userId withPage:page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseFavorThreadListFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler {

    NSString *url = [self.forumConfig searchNewThread:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewSearchForumPage *searchForumPage = [self.forumParser parseSearchPageFromHtml:html];
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
            ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, sarchPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

    NSString *baseUrl = [self.forumConfig searchThreadWithUserId:[NSString stringWithFormat:@"%d", userId]];

    NSString * url = [baseUrl stringByAppendingFormat:@"%d", page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, sarchPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {

    //https://www.chiphell.com/thread-1732141-2-1.html

    NSString *url = [self.forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
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
    NSString *url = [self.forumConfig forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {

    NSString *url = [self.forumConfig memberWithUserId:userId];

    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [self.forumParser parseUserAvatar:html userId:userId];
        if (avatar) {
            avatar = [self.forumConfig.avatarBase stringByAppendingString:avatar];
        } else {
            avatar = self.forumConfig.avatarNo;
        }
        handler(isSuccess, avatar);
    }];
}

- (void)listSearchResultWithSearchId:(NSString *)searchid keyWord:(NSString *)keyWord andPage:(int)page handler:(HandlerWithBool)handler {
}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig memberWithUserId:userId];
    [self GET:url requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [self.forumParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

//------

// private
- (void)saveUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] saveUserName:name];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

//------

@end

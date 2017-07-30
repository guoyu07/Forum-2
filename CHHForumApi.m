//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "CHHForumApi.h"
#import "NSUserDefaults+Extensions.h"
#import "DeviceName.h"
#import "NSString+Extensions.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import "UIButton+AFNetworking.h"
#import "ForumParserDelegate.h"
#import "NSUserDefaults+Setting.h"

#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"


@implementation CHHForumApi {

}

- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString *)code question:(NSString *)q answer:(NSString *)a handler:(HandlerWithBool)handler {

    [self.browser GETWithURLString:self.forumConfig.login parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess){

            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:name forKey:@"vb_login_username"];
            [parameters setValue:@"" forKey:@"vb_login_password"];
            [parameters setValue:@"1" forKey:@"cookieuser"];
            [parameters setValue:@"" forKey:@"vcode"];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:@"guest" forKey:@"securitytoken"];
            [parameters setValue:@"login" forKey:@"do"];

            NSString *md5pwd = [passWord md5HexDigest];
            [parameters setValue:md5pwd forKey:@"vb_login_md5password"];
            [parameters setValue:md5pwd forKey:@"vb_login_md5password_utf"];

            [self.browser POSTWithURLString:self.forumConfig.login parameters:parameters charset:UTF_8 requestCallback:^(BOOL success, NSString *resultHtml) {
                if (success) {

                    NSString *userName = [resultHtml stringWithRegular:@"<p><strong>.*</strong></p>" andChild:@"，.*。"];
                    userName = [userName substringWithRange:NSMakeRange(1, [userName length] - 2)];

                    if (userName != nil) {
                        // 保存Cookie
                        [self saveCookie];
                        // 保存用户名
                        [self saveUserName:userName];
                        handler(YES, @"登录成功");
                    } else {
                        handler(NO, [self.forumParser parseLoginErrorMessage:resultHtml]);
                    }

                } else {
                    handler(NO, [self.forumParser parseLoginErrorMessage:resultHtml]);
                }
            }];

        } else{

        }
    }];



}

-(long long)getRandomNumber:(long long)from to:(long long)to{
    
    return (long)(from + (arc4random() % (to - from + 1)));
    //return srandom((unsigned int) time(NULL));//srand(unsigned(time(NULL)));
}

- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView {
    [self.browser GETWithURLString:self.forumConfig.login parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess){
            NSString * seccodeFull = [html stringWithRegular:@"<span id=\"seccode_\\w+\"></span>" andChild:@"seccode_\\w+"];
            NSString * seccode = [seccodeFull componentsSeparatedByString:@"_"][1];
            NSLog(@"seccode is : %@", seccode);

            NSString * msicT = @"http://www.chiphell.com/misc.php?mod=seccode&action=update&idhash=%@&0.%lld&modid=member::logging";
            long long random = [self getRandomNumber:100000000000000L to:999999999999999L];
            NSString * msic = [NSString stringWithFormat:msicT, seccode, random];
            NSLog(@"seccode is : %@", msic);
            
            //NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

            [self saveCookie];
            
            
            NSMutableDictionary *p = [NSMutableDictionary dictionary];
            [p setValue:[self loadCookie] forKey:@"cookie"];
            
            [self.browser GETWithURLString:msic parameters:p charset:UTF_8 requestCallback:^(BOOL success, NSString *codeHtml) {
                if (success){
                    
                    [self saveCookie];
                    
                    NSLog(@"codehtml is : %@", codeHtml);

                    NSString * picT = [codeHtml stringWithRegular:@"misc\\.php\\?mod=seccode&update=\\d+&idhash=\\w+"];

                    NSLog(@"picT is : %@", picT);
                    
                    NSString *url = [@"http://www.chiphell.com/" stringByAppendingString:picT];//self.forumConfig.loginvCode;
                    
                    AFImageDownloader *downloader = [[vCodeImageView class] sharedImageDownloader];
                    id <AFImageRequestCache> imageCache = downloader.imageCache;
                    [imageCache removeImageWithIdentifier:url];
                    
                    NSURL *URL = [NSURL URLWithString:url];
                    
                    //NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                    
                    
                    
                    NSMutableURLRequest *msrequest = [NSMutableURLRequest requestWithURL:URL];
                    [msrequest setValue: [self loadCookie] forHTTPHeaderField: @"Cookie"];
                    
                    
                    UIImageView *view = vCodeImageView;
                    
                    [vCodeImageView setImageWithURLRequest:msrequest placeholderImage:nil success:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, UIImage *_Nonnull image) {
                        [view setImage:image];
                    }                              failure:^(NSURLRequest *_Nonnull urlRequest, NSHTTPURLResponse *_Nullable response, NSError *_Nonnull error) {
                        NSLog(@"refreshDoor failed");
                    }];
                    
                }
            }];
        }
    }];

    
}

- (LoginUser *)getLoginUser {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];

    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [self userName:self.currentConfigDelegate.forumURL.host];

    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[(NSUInteger) i];

        if ([cookie.name isEqualToString:self.forumConfig.cookieUserIdKey]) {
            user.userID = [cookie.value componentsSeparatedByString:@"%"][0];
        } else if ([cookie.name isEqualToString:self.forumConfig.cookieExpTimeKey]) {
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
    [self.browser GETWithURLString:self.forumConfig.archive parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
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

- (void)createNewThreadWithForumId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {

}

- (void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler {

}

- (void)seniorReplyWithThreadId:(int)threadId forForumId:(int)forumId replyPostId:(int)replyPostId
                     andMessage:(NSString *)message
                     withImages:(NSArray *)images
                  securitytoken:(NSString *)token handler:(HandlerWithBool)handler {

    NSString *msg = message;

    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        msg = [message stringByAppendingString:[self buildSignature]];
    }

    if (replyPostId == -1){     // 表示回复的某一个楼层
        NSString *preReplyUrl = [NSString stringWithFormat:@"https://www.chiphell.com/forum.php?mod=post&action=reply&fid=%d&tid=%d&reppost=%d&extra=page%3D1&page=1&infloat=yes&handlekey=reply&inajax=1&ajaxtarget=fwin_content_reply", forumId, threadId, replyPostId];

        [self.browser GETWithURLString:preReplyUrl parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
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

//                long time = (long) [[NSDate date] timeIntervalSince1970];
//                [parameters setValue:[NSString stringWithFormat:@"%li", time] forKey:@"posttime"];
//                [parameters setValue:@"" forKey:@"wysiwyg"];
//                [parameters setValue:@"0" forKey:@"save"];

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

- (void)showPrivateMessageContentWithId:(int)pmId handler:(HandlerWithBool)handler {

}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (void)favoriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)unfavouriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {

    [self.browser GETWithURLString:[self.forumConfig privateWithType:type withPage:page] parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
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
    [self.browser GETWithURLString:favForumsURL parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig listfavThreadWithId:page];

    [self.browser GETWithURLString:url parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseFavThreadListFromHtml:html];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {

    [self.browser GETWithURLString:[self.forumConfig searchNewThread:page] parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewSearchForumPage *searchForumPage = [self.forumParser parseSearchPageFromHtml:html];
            handler(isSuccess, searchForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    [self.browser GETWithURLString:nil parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
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

    NSMutableDictionary *defparameters = [NSMutableDictionary dictionary];

    [self.browser GETWithURLString:url parameters:defparameters charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {

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
    [self.browser GETWithURLString:url parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            NSString *error = nil;//[self checkError:html];
            if (error != nil) {
                handler(NO, error);
            } else {
                ViewThreadPage *detail = [self.forumParser parseShowThreadWithHtml:html];
                handler(isSuccess, detail);
            }
        } else {
            handler(NO, html);
        }

    }];
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {

}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {

    [self.browser GETWithURLString:[self.forumConfig forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page] parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            ViewForumPage *viewForumPage = [self.forumParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, viewForumPage);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {

    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
        NSString *avatar = [self.forumParser parseUserAvatar:html userId:userId];
        if (avatar) {
            avatar = [self.forumConfig.avatarBase stringByAppendingString:avatar];
        } else {
            avatar = self.forumConfig.avatarNo;
        }
        handler(isSuccess, avatar);
    }];

}

- (void)listSearchResultWithSearchid:(NSString *)searchid andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:nil charset:UTF_8 requestCallback:^(BOOL isSuccess, NSString *html) {
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

- (id <ForumConfigDelegate>)currentConfigDelegate {
    return self.forumConfig;
}

//------
// private
- (NSString *)loadCookie {
    return [[NSUserDefaults standardUserDefaults] loadCookie];
}

// private
- (void)saveUserName:(NSString *)name {
    [[NSUserDefaults standardUserDefaults] saveUserName:name];
}

//private
- (NSString *)userName:(NSString *)host {
    return [[NSUserDefaults standardUserDefaults] userName:host];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

// private
- (NSString *)buildSignature {
    NSString *phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 CHH客户端", phoneName];
    return signature;
}

//------

@end

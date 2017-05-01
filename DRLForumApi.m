//
// Created by WDY on 2016/12/8.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import "DRLForumApi.h"

#import "NSString+Extensions.h"
#import "NSUserDefaults+Extensions.h"
#import "NSUserDefaults+Setting.h"
#import "AFHTTPSessionManager+SimpleAction.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "DeviceName.h"

//#define kCookieUser @"bbuserid"
//#define kCookieLastVisit @"bblastvisit"
//#define kCookieIDStack @"IDstack"
#define kSecurityToken @"securitytoken"

typedef void (^CallBack)(NSString *token, NSString *hash, NSString *time);

@implementation DRLForumApi {
    NSString *listMyThreadSearchId;

    NSMutableDictionary *listUserThreadRedirectUrlDictionary;

    NSString *todayNewThreadPostSearchId;

    // senior post
    NSArray *toUploadImages;
    HandlerWithBool _handlerWithBool;
    NSString *_message;
    NSString *_subject;
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
- (NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] userName];
}

//private
- (void)saveCookie {
    [[NSUserDefaults standardUserDefaults] saveCookie];
}

// private
- (NSString *)buildSignature {
    NSString * phoneName = [DeviceName deviceNameDetail];
    NSString *signature = [NSString stringWithFormat:@"\n\n发自 %@ 使用 DRL客户端", phoneName];
    return signature;
}

//------

- (void)loginWithName:(NSString *)name andPassWord:(NSString *)passWord withCode:(NSString *)code handler:(HandlerWithBool)handler {
    [self.browser GETWithURLString:self.forumConfig.login parameters:nil requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            
            [self saveCookie];
            
            NSString * md5pwd = [passWord md5HexDigest];
            
            NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"login" forKey:@"do"];
            [parameters setValue:@"1" forKey:@"forceredirect"];
            [parameters setValue:@"/index.php?s=" forKey:@"url"];
            [parameters setValue:md5pwd forKey:@"vb_login_md5password"];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:name forKey:@"vb_login_username"];
            [parameters setValue:@"" forKey:@"vb_login_password"];
            [parameters setValue:code forKey:@"vcode"];
            
            [parameters setValue:@"1" forKey:@"cookieuser"];
            
            [self.browser POSTWithURLString:self.forumConfig.login parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                if (isSuccess) {
                    
                    NSString * userName = [html stringWithRegular:@"<p><strong>.*</strong></p>" andChild:@"，.*。"];
                    
                    userName = [userName substringWithRange:NSMakeRange(1, [userName length] -2)];
                    
                    if (userName != nil) {
                        // 保存Cookie
                        [self saveCookie];
                        // 保存用户名
                        [self saveUserName:userName];
                        handler(YES, @"登录成功");
                    } else {
                        handler(NO, [self.forumParser parseLoginErrorMessage:html]);
                    }
                } else{
                    handler(NO,html);
                }
            }];
            
        } else{
            
        }
    }];
}

- (void)refreshVCodeToUIImageView:(UIImageView *)vCodeImageView {
    NSString *url = self.forumConfig.loginvCode;
    
    AFImageDownloader *downloader = [[vCodeImageView class] sharedImageDownloader];
    id <AFImageRequestCache> imageCache = downloader.imageCache;
    [imageCache removeImageWithIdentifier:url];
    
    NSURL *URL = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    UIImageView *view = vCodeImageView;
    
    [vCodeImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *_Nonnull request, NSHTTPURLResponse *_Nullable response, UIImage *_Nonnull image) {
        [view setImage:image];
    } failure:^(NSURLRequest *_Nonnull request, NSHTTPURLResponse *_Nullable response, NSError *_Nonnull error) {
        NSLog(@"refreshDoor failed");
    }];
}

- (LoginUser *)getLoginUser {
    NSArray<NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    LoginUser *user = [[LoginUser alloc] init];
    user.userName = [self userName];
    
    for (int i = 0; i < cookies.count; i++) {
        NSHTTPCookie *cookie = cookies[i];

        if ([cookie.name isEqualToString:self.forumConfig.cookieLastVisitTimeKey]) {
            user.lastVisit = cookie.value;
        } else if ([cookie.name isEqualToString:self.forumConfig.cookieUserIdKey]) {
            user.userID = cookie.value;
        } else if ([cookie.name isEqualToString:self.forumConfig.cookieExpTimeKey]) {
            user.expireTime = cookie.expiresDate;
        }
    }
    return user;
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
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:self.forumConfig.archive parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
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

// private 正式开始发送
- (void)doPostThread:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withToken:(NSString *)token withHash:(NSString *)hash postTime:(NSString *)time handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:subject forKey:@"subject"];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"iconid"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"postthread" forKey:@"do"];
    [parameters setValue:hash forKey:@"posthash"];
    
    
    [parameters setValue:time forKey:@"poststarttime"];
    
    LoginUser *user = [self getLoginUser];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"发表主题" forKey:@"sbutton"];
    [parameters setValue:@"1" forKey:@"parseurl"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];
    [parameters setValue:@"4" forKey:@"polloptions"];
    
    
    [self.browser POSTWithURLString:[self.forumConfig newThreadWithForumId:[NSString stringWithFormat:@"%d", fId]] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            [self saveCookie];
        }
        handler(isSuccess, html);
        
    }];
}

// private 进入图片管理页面，准备上传图片
- (void)uploadImagePrepair:(int)forumId startPostTime:(NSString *)time postHash:(NSString *)hash :(HandlerWithBool)callback {

    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:[self.forumConfig newattachmentForForum:forumId time:time postHash:hash] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}

// private
- (void)uploadImagePrepairFormSeniorReply:(int)threadId startPostTime:(NSString *)time postHash:(NSString *)hash :(HandlerWithBool)callback {
    NSString *url = [self.forumConfig newattachmentForThread:threadId time:time postHash:hash];
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        callback(isSuccess, html);
    }];
}

// private 开始上传图片
- (void)uploadFile:(NSString *)token fId:(NSString *)fId postTime:(NSString *)postTime hash:(NSString *)hash image:(NSData *)image {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:@"" forKey:@"t"];
    [parameters setValue:fId forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];
    NSString *name = [NSString stringWithFormat:@"Forum_Client_%f.jpg", [[NSDate date] timeIntervalSince1970]];
    
    [parameters setValue:name forKey:@"attachment[]"];
    
    [parameters setValue:@"" forKey:@"attachmenturl[]"];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
    [parameters setValue:fileName forKey:@"attachment[]"];
    
    
    
    //[self.browser.requestSerializer setValue:@"multipart/form-data; boundary=----WebKitFormBoundaryG9KMXkoSxJnZByFF" forHTTPHeaderField:@"Content-Type"];
    
    [self.browser POSTWithURLString:self.forumConfig.newattachment parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
        NSString *type = [self contentTypeForImageData:image];
        
        //[formData appendPartWithFileData:image name:@"attachment[]" fileName:@"abc123.jpeg" mimeType:type];
        
        UIImage *image = [UIImage imageNamed:@"test.jpg"];
        NSData *data = UIImageJPEGRepresentation(image, 1);
        
        
        [formData appendPartWithFileData:data name:@"attachment[]" fileName:fileName mimeType:type];
        
        //[formData appendPartWithFormData:data name:fileName];
        
    }           requestCallback:^(BOOL isSuccess, NSString *html) {
        
        NSLog(@"上传结果-------->>>>>>>> :   %@", html);
        NSLog(@"上传结果-------->>>>>>>> 上传结束");
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

// private
- (void)uploadImage:(NSURL *)url :(NSString *)token fId:(int)fId postTime:(NSString *)postTime hash:(NSString *)hash :(NSData *)imageData callback:(HandlerWithBool)callback {
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSString *cookie = [self loadCookie];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    
    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:token forHTTPHeaderField:@"securitytoken"];
    
    
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    
    
    // add params (all params are strings)
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:@"" forKey:@"t"];
    NSString *forumId = [NSString stringWithFormat:@"%d", fId];
    [parameters setValue:forumId forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    [parameters setValue:@"16777216" forKey:@"MAX_FILE_SIZE"];
    [parameters setValue:@"上传" forKey:@"upload"];
    
    
    NSString *name = [NSString stringWithFormat:@"Forum_Client_%f.jpg", [[NSDate date] timeIntervalSince1970]];
    
    [parameters setValue:name forKey:@"attachment[]"];
    
    [parameters setValue:name forKey:@"attachmenturl[]"];
    
    
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    
    // add image data
    if (imageData) {
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"attachment[]", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data.length > 0) {
            //success
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, responseString);
        } else {
            callback(NO, @"failed");
        }
    }];
}

//private  获取发新帖子的Posttime hash 和token
- (void)createNewThreadPrepair:(int)forumId :(CallBack)callback {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:[self.forumConfig newThreadWithForumId:[NSString stringWithFormat:@"%d", forumId]] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];
            NSString *postTime = [[token componentsSeparatedByString:@"-"] firstObject];
            NSString *hash = [self.forumParser parsePostHash:html];
            
            callback(token, hash, postTime);
        } else {
            callback(nil, nil, nil);
        }
        
    }];
}

- (void)createNewThreadWithForumId:(int)fId withSubject:(NSString *)subject andMessage:(NSString *)message withImages:(NSArray *)images handler:(HandlerWithBool)handler {
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
        
    }
    
    // 准备发帖
    [self createNewThreadPrepair:fId :^(NSString *token, NSString *hash, NSString *time) {
        
        if (images == nil || images.count == 0) {
            // 没有图片，直接发送主题
            [self doPostThread:fId withSubject:subject andMessage:message withToken:token withHash:hash postTime:time handler:^(BOOL isSuccess, NSString * result) {
                
                if ([result containsString:@"此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。"]){
                    handler(NO, @"此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。");
                } else if ([result containsString:@"您输入的信息太短，您发布的信息至少为 5 个字符。"]){
                    handler(NO, @"您输入的信息太短，您发布的信息至少为 5 个字符。");
                } else{
                    ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:result];
                    if (thread.postList.count > 0) {
                        handler(YES, thread);
                    } else {
                        handler(NO, @"未知错误");
                    }
                }
                
            }];
        } else {
            // 如果有图片，先传图片
            [self uploadImagePrepair:fId startPostTime:time postHash:hash :^(BOOL isSuccess, NSString *result) {
                
                // 解析出上传图片需要的参数
                NSString *uploadToken = [self.forumParser parseSecurityToken:result];
                NSString *uploadTime = [[token componentsSeparatedByString:@"-"] firstObject];
                NSString *uploadHash = [self.forumParser parsePostHash:result];
                
                __block BOOL uploadSuccess = YES;
                for (int i = 0; i < images.count && uploadSuccess; i++) {
                    NSData *image = images[(NSUInteger) i];
                    
                    [NSThread sleepForTimeInterval:2.0f];
                    
                    NSURL *url = [NSURL URLWithString:self.forumConfig.newattachment];
                    [self uploadImage:url :uploadToken fId:fId postTime:uploadTime hash:uploadHash :image callback:^(BOOL isSuccess, id result) {
                        uploadSuccess = isSuccess;
                        
                        if (i == images.count - 1) {
                            [NSThread sleepForTimeInterval:2.0f];
                            [self doPostThread:fId withSubject:subject andMessage:message withToken:token withHash:hash postTime:time handler:^(BOOL isSuccess, id result) {
                                
                                if ([result containsString:@"此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。"]){
                                    handler(NO, @"此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。");
                                } else if ([result containsString:@"您输入的信息太短，您发布的信息至少为 5 个字符。"]){
                                    handler(NO, @"您输入的信息太短，您发布的信息至少为 5 个字符。");
                                } else{
                                    ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:result];
                                    if (thread.postList.count > 0) {
                                        handler(YES, thread);
                                    } else {
                                        handler(NO, @"未知错误");
                                    }
                                }
                                
                            }];
                        }
                    }];
                }
                
                if (!uploadSuccess) {
                    handler(NO, @"上传图片失败！");
                }
                
            }];
        }
        
    }];
    
}

// private
- (NSString *)readSecurityToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:kSecurityToken];
}

- (void)replyThreadWithId:(int)threadId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }
    
    NSURL *loginUrl = [NSURL URLWithString:[self.forumConfig newReplyWithThreadId:threadId]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *securitytoken = [self readSecurityToken];
    
    [parameters setValue:securitytoken forKey:@"securitytoken"];
    [parameters setValue:message forKey:@"message"];
    
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:@"who cares" forKey:@"p"];
    
    [parameters setValue:@"0" forKey:@"specifiedpost"];
    
    [parameters setValue:@"1" forKey:@"parseurl"];
    
    LoginUser *user = [self getLoginUser];
    
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"1" forKey:@"fromquickreply"];
    
    [parameters setValue:@"0" forKey:@"styleid"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    
    [parameters setValue:@"" forKey:@"s"];
    
    [self.browser POSTWithURLString:[loginUrl absoluteString] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (isSuccess) {
            // 保存Cookie
            [self saveCookie];
            
            if ([html containsString:@"此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。"]){
                handler(NO, @"此帖是您在最后 5 分钟发表的帖子的副本，您将返回该主题。");
            } else if ([html containsString:@"您输入的信息太短，您发布的信息至少为 5 个字符。"]){
                handler(NO, @"您输入的信息太短，您发布的信息至少为 5 个字符。");
            } else {
                ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:message];
                if (thread.postList.count > 0) {
                    handler(YES, thread);
                } else {
                    handler(NO, @"未知错误");
                }
            }
        } else{
            handler(NO, html);
        }
        
        if (isSuccess) {
            // 保存Cookie
            [self saveCookie];
            
            handler(YES, html);
            
        } else {
            handler(NO, html);
        }
    }];
}

- (void)quickReplyPostWithThreadId:(int)threadId forPostId:(int)postId andMessage:(NSString *)message securitytoken:(NSString *)token ajaxLastPost:(NSString *)ajax_lastpost handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig newReplyWithThreadId:threadId];
    
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"0" forKey:@"wysiwyg"];
    [parameters setValue:@"0" forKey:@"styleid"];
    [parameters setValue:@"1" forKey:@"signature"];
    [parameters setValue:@"1" forKey:@"quickreply"];
    [parameters setValue:@"1" forKey:@"fromquickreply"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:token forKey:@"securitytoken"];
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:[NSString stringWithFormat:@"%d", postId] forKey:@"p"];
    [parameters setValue:@"1" forKey:@"specifiedpost"];
    [parameters setValue:@"1" forKey:@"parseurl"];
    
    LoginUser *user = [self getLoginUser];
    [parameters setValue:user.userID forKey:@"loggedinuser"];
    [parameters setValue:@"sbutton" forKey:@"快速回复帖子"];
    
    [self.browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess){
            if ([html containsString:@"<ol><li>本论坛允许的发表两个帖子的时间间隔必须大于 30 秒。请等待 "] || [html containsString:@"<ol><li>本論壇允許的發表兩個文章的時間間隔必須大於 30 秒。請等待"]){
                handler(NO, @"本论坛允许的发表两个帖子的时间间隔必须大于 30 秒");
            } else{
                ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:html];
                if (thread.postList.count > 0) {
                    handler(YES, thread);
                } else {
                    handler(NO, @"未知错误");
                }
            }
        } else{
            handler(NO, html);
        }
    }];
    
}

// private
- (void)seniorReplyWithThreadId:(int)threadId andMessage:(NSString *)message posthash:(NSString *)posthash poststarttime:(NSString *)poststarttime handler:(HandlerWithBool)handler {
    
    NSString *url = [self.forumConfig newReplyWithThreadId:threadId];
    
    if ([NSUserDefaults standardUserDefaults].isSignatureEnabled) {
        message = [message stringByAppendingString:[self buildSignature]];
    }
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"" forKey:@"title"];
    [parameters setValue:@"0" forKey:@"mode"];
    [parameters setValue:message forKey:@"message"];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"postreply" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:posthash forKey:@"posthash"];
    [parameters setValue:poststarttime forKey:@"poststarttime"];
    [parameters setValue:@"发表回复" forKey:@"sbutton"];
    [parameters setValue:@"9999" forKey:@"emailupdate"];
    [parameters setValue:@"0" forKey:@"rating"];
    
    [self.browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

// private
- (NSString *)uploadParamDivider {
    static const NSString *kRandomAlphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:16];
    for (int i = 0; i < 16; i++) {
        [randomString appendFormat:@"%C", [kRandomAlphabet characterAtIndex:arc4random_uniform((u_int32_t) [kRandomAlphabet length])]];
    }
    return randomString;
}

// private
- (void)uploadImageForSeniorReply:(NSURL *)url fId:(int)fId threadId:(int)threadId postTime:(NSString *)postTime hash:(NSString *)hash :(NSData *)imageData callback:(HandlerWithBool)callback {
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPShouldHandleCookies:YES];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSString *cookie = [self loadCookie];
    [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    
    NSString *boundary = [NSString stringWithFormat:@"----WebKitFormBoundary%@", [self uploadParamDivider]];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    
    
    // add params (all params are strings)
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"manageattach" forKey:@"do"];
    [parameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [parameters setValue:[NSString stringWithFormat:@"%d", fId] forKey:@"f"];
    [parameters setValue:@"" forKey:@"p"];
    [parameters setValue:postTime forKey:@"poststarttime"];
    [parameters setValue:@"0" forKey:@"editpost"];
    [parameters setValue:hash forKey:@"posthash"];
    [parameters setValue:@"20971520" forKey:@"MAX_FILE_SIZE"];
    
    [parameters setValue:@"" forKey:@"attachment2"];
    [parameters setValue:@"" forKey:@"attachment3"];
    [parameters setValue:@"" forKey:@"attachment4"];
    [parameters setValue:@"" forKey:@"attachment5"];
    
    [parameters setValue:@"上传" forKey:@"upload"];
    
    
    for (NSString *param in parameters) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [parameters objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    
    // add image data
    if (imageData) {
        NSString *name = [NSString stringWithFormat:@"Forum_Client_%f.jpg", [[NSDate date] timeIntervalSince1970]];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"attachment1", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long) [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data.length > 0) {
            //success
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, responseString);
        } else {
            callback(NO, @"failed");
        }
    }];
}

- (void)seniorReplyWithThreadId:(int)threadId forForumId:(int)forumId andMessage:(NSString *)message withImages:(NSArray *)images securitytoken:(NSString *)token handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig newReplyWithThreadId:threadId];
    
    
    NSMutableDictionary *presparameters = [NSMutableDictionary dictionary];
    [presparameters setValue:@"" forKey:@"message"];
    [presparameters setValue:@"1" forKey:@"fromquickreply"];
    [presparameters setValue:@"" forKey:@"s"];
    [presparameters setValue:@"postreply" forKey:@"do"];
    [presparameters setValue:[NSString stringWithFormat:@"%d", threadId] forKey:@"t"];
    [presparameters setValue:@"who cares" forKey:@"p"];
    [presparameters setValue:@"1" forKey:@"parseurl"];
    [presparameters setValue:@"高级模式" forKey:@"preview"];
    [presparameters setValue:@"高级模式" forKey:@"clickedelm"];
    
    [self.browser POSTWithURLString:url parameters:presparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            
            NSString *postHash = [self.forumParser parsePostHash:html];
            NSString *postStartTime = [self.forumParser parserPostStartTime:html];
            
            if (images == nil || [images count] == 0) {
                [self seniorReplyWithThreadId:threadId andMessage:message posthash:postHash poststarttime:postStartTime handler:^(BOOL isSuccess, id result) {
                    if (isSuccess){
                        if ([html containsString:@"<ol><li>本论坛允许的发表两个帖子的时间间隔必须大于 30 秒。请等待 "]){
                            handler(NO, @"本论坛允许的发表两个帖子的时间间隔必须大于 30 秒");
                        } else{
                            ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:result];
                            if (thread.postList.count > 0) {
                                handler(YES, thread);
                            } else {
                                handler(NO, @"未知错误");
                            }
                        }
                    } else{
                        handler(NO, html);
                    }
                }];
                
            } else {
                
                NSString *urlStr = self.forumConfig.newattachment;
                NSURL *uploadImageUrl = [NSURL URLWithString:urlStr];
                // 如果有图片，先传图片
                [self uploadImagePrepairFormSeniorReply:threadId startPostTime:postStartTime postHash:postHash :^(BOOL isSuccess, id result) {
                    
                    __block BOOL uploadSuccess = YES;
                    int uploadCount = (int) images.count;
                    for (int i = 0; i < uploadCount && uploadSuccess; i++) {
                        NSData *image = images[i];
                        
                        [NSThread sleepForTimeInterval:2.0f];
                        [self uploadImageForSeniorReply:uploadImageUrl fId:forumId threadId:threadId postTime:postStartTime hash:postHash :image callback:^(BOOL isSuccess, id uploadResultHtml) {
                            uploadSuccess = isSuccess;
                            // 更新token
                            NSLog(@" 上传第 %d 张图片", i);
                            
                            if (i == images.count - 1) {
                                [NSThread sleepForTimeInterval:2.0f];
                                [self seniorReplyWithThreadId:threadId andMessage:message posthash:postHash poststarttime:postStartTime handler:^(BOOL isSuccess, id resultHtml) {
                                    
                                    if (isSuccess){
                                        if ([html containsString:@"<ol><li>本论坛允许的发表两个帖子的时间间隔必须大于 30 秒。请等待 "]){
                                            handler(NO, @"本论坛允许的发表两个帖子的时间间隔必须大于 30 秒");
                                        } else{
                                            ViewThreadPage *thread = [self.forumParser parseShowThreadWithHtml:resultHtml];
                                            if (thread.postList.count > 0) {
                                                handler(YES, thread);
                                            } else {
                                                handler(NO, @"未知错误");
                                            }
                                        }
                                    } else{
                                        handler(NO, html);
                                    }
                                    
                                }];
                            }
                        }];
                    }
                    
                    if (!uploadSuccess) {
                        handler(NO, @"上传图片失败！");
                    }
                }];
            }
        } else {
            handler(NO, @"回复失败");
        }
    }];
}

// private
- (void)saveSecurityToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kSecurityToken];
}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    
    [parameters setValue:@"" forKey:@"s"];
    [parameters setValue:@"process" forKey:@"do"];
    [parameters setValue:@"" forKey:@"searchthreadid"];
    
    if (type == 0) {
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"1" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 1) {
        [parameters setValue:keyWord forKey:@"query"];
        [parameters setValue:@"0" forKey:@"titleonly"];
        [parameters setValue:@"" forKey:@"searchuser"];
        [parameters setValue:@"0" forKey:@"starteronly"];
    } else if (type == 2) {
        [parameters setValue:@"1" forKey:@"starteronly"];
        [parameters setValue:@"" forKey:@"query"];
        [parameters setValue:@"1" forKey:@"titleonly"];
        [parameters setValue:keyWord forKey:@"searchuser"];
    }
    
    
    [parameters setValue:@"1" forKey:@"exactname"];
    [parameters setValue:@"0" forKey:@"replyless"];
    [parameters setValue:@"0" forKey:@"replylimit"];
    [parameters setValue:@"0" forKey:@"searchdate"];
    [parameters setValue:@"after" forKey:@"beforeafter"];
    [parameters setValue:@"lastpost" forKey:@"sortby"];
    [parameters setValue:@"descending" forKey:@"order"];
    [parameters setValue:@"0" forKey:@"showposts"];
    [parameters setValue:@"" forKey:@"tag"];
    [parameters setValue:@"0" forKey:@"forumchoice[]"];
    [parameters setValue:@"1" forKey:@"childforums"];
    [parameters setValue:@"1" forKey:@"saveprefs"];

    NSMutableDictionary * defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:self.forumConfig.search parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];
            if (token != nil) {
                [self saveSecurityToken:token];
            }
            
            NSString *securitytoken = [self readSecurityToken];
            [parameters setValue:securitytoken forKey:@"securitytoken"];
            
            [self.browser POSTWithURLString:self.forumConfig.search parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                if (isSuccess) {
                    [self saveCookie];
                    
                    if ([html containsString:@"对不起，没有匹配记录。请尝试采用其他条件查询。"]) {
                        handler(NO, @"对不起，没有匹配记录。请尝试采用其他条件查询。");
                    } else if ([html containsString:@"本论坛允许的进行两次搜索的时间间隔必须大于 30 秒。"]){
                        handler(NO, @"本论坛允许的进行两次搜索的时间间隔必须大于 30 秒。");
                    } else{
                        ViewSearchForumPage *page = [self.forumParser parseSearchPageFromHtml:html];
                        
                        if (page != nil && page.threadList != nil && page.threadList.count > 0) {
                            handler(YES, page);
                        } else {
                            handler(NO, @"未知错误");
                        }
                    }
                } else {
                    handler(NO, html);
                }
                
            }];
        } else {
            handler(NO, html);
        }
    }];
    
}

- (void)showPrivateContentById:(int)pmId handler:(HandlerWithBool)handler {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:[self.forumConfig privateShowWithMessageId:pmId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
    if (isSuccess) {
        ViewMessagePage *content = [self.forumParser parsePrivateMessageContent:html avatarBase:self.forumConfig.avatarBase noavatar:self.forumConfig.avatarNo];
        handler(YES, content);
    } else {
        handler(NO, html);
    }
}];
}

- (void)sendPrivateMessageToUserName:(NSString *)name andTitle:(NSString *)title andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSMutableDictionary * defparameters = [NSMutableDictionary dictionary];
    [defparameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:self.forumConfig.privateNewPre parameters:defparameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:message forKey:@"message"];
            [parameters setValue:title forKey:@"title"];
            [parameters setValue:@"0" forKey:@"pmid"];
            [parameters setValue:name forKey:@"recipients"];
            [parameters setValue:@"0" forKey:@"wysiwyg"];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"0" forKey:@"forward"];
            [parameters setValue:@"1" forKey:@"savecopy"];
            [parameters setValue:@"提交信息" forKey:@"sbutton"];
            [parameters setValue:@"1" forKey:@"parseurl"];
            [parameters setValue:@"insertpm" forKey:@"do"];
            [parameters setValue:@"" forKey:@"bccrecipients"];
            [parameters setValue:@"0" forKey:@"iconid"];
            
            [self.browser POSTWithURLString:self.forumConfig.privateReplyWithMessage parameters:parameters requestCallback:^(BOOL success, NSString *result) {
                if (success) {
                    if ([result containsString:@"信息提交时发生如下错误:"] || [result containsString:@"訊息提交時發生如下錯誤:"]) {
                        handler(NO, @"收件人未找到或者未填写标题");
                    } else {
                        handler(YES, @"");
                    }
                } else {
                    handler(NO, result);
                }
            }];
        } else {
            handler(NO, nil);
        }
        
        
    }];
}

- (void)replyPrivateMessageWithId:(int)pmId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];

    [self.browser GETWithURLString:[self.forumConfig privateShowWithMessageId:pmId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSString *token = [self.forumParser parseSecurityToken:html];
            
            NSString *quote = [self.forumParser parseQuickReplyQuoteContent:html];
            
            NSString *title = [self.forumParser parseQuickReplyTitle:html];
            NSString *name = [self.forumParser parseQuickReplyTo:html];
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            
            NSString *realMessage = [[quote stringByAppendingString:@"\n"] stringByAppendingString:message];
            
            [parameters setValue:realMessage forKey:@"message"];
            [parameters setValue:@"0" forKey:@"wysiwyg"];
            [parameters setValue:@"6" forKey:@"styleid"];
            [parameters setValue:@"1" forKey:@"fromquickreply"];
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:@"insertpm" forKey:@"do"];
            [parameters setValue:[NSString stringWithFormat:@"%d", pmId] forKey:@"pmid"];
            //[parameters setValue:@"0" forKey:@"loggedinuser"]; 经过测试，这个参数不写也行
            [parameters setValue:@"1" forKey:@"parseurl"];
            [parameters setValue:@"1" forKey:@"signature"];
            [parameters setValue:title forKey:@"title"];
            [parameters setValue:name forKey:@"recipients"];
            
            [parameters setValue:@"0" forKey:@"forward"];
            [parameters setValue:@"1" forKey:@"savecopy"];
            [parameters setValue:@"提交信息" forKey:@"sbutton"];
            
            [self.browser POSTWithURLString:[self.forumConfig privateReplyWithMessageIdPre:pmId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                handler(isSuccess, html);
            }];
            
        } else {
            handler(NO, nil);
        }
    }];
}

- (void)favoriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *preUrl = [self.forumConfig favForumWithId:forumId];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:preUrl parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (!isSuccess) {
            handler(NO, html);
        } else {
            
            NSString *url = [self.forumConfig favForumWithIdParam:forumId];
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            
            NSString *paramUrl = [self.forumConfig forumDisplayWithId:forumId];
            
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:@"addsubscription" forKey:@"do"];
            [parameters setValue:forumId forKey:@"forumid"];
            [parameters setValue:paramUrl forKey:@"url"];
            [parameters setValue:@"0" forKey:@"emailupdate"];
            
            [self.browser POSTWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                handler(isSuccess, html);
            }];
            
        }
    }];
}

- (void)unfavouriteForumsWithId:(NSString *)forumId handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig unfavForumWithId:forumId];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)favoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    NSString *preUrl = [self.forumConfig favThreadWithIdPre:threadPostId];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:preUrl parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (!isSuccess) {
            handler(NO, html);
        } else {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            
            [parameters setValue:@"" forKey:@"s"];
            [parameters setValue:@"addsubscription" forKey:@"do"];
            [parameters setValue:threadPostId forKey:@"threadid"];
            
            NSString *urlPram = [self.forumConfig showThreadWithThreadId:threadPostId];
            [parameters setValue:urlPram forKey:@"url"];
            
            [parameters setValue:@"0" forKey:@"emailupdate"];
            [parameters setValue:@"0" forKey:@"folderid"];
            
            NSString *fav = [self.forumConfig favThreadWithId:threadPostId];
            [self.browser POSTWithURLString:fav parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                handler(isSuccess, html);
            }];
        }
    }];
}

- (void)unfavoriteThreadPostWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig unfavThreadWithId:threadPostId];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        handler(isSuccess, html);
    }];
}

- (void)listPrivateMessageWithType:(int)type andPage:(int)page handler:(HandlerWithBool)handler {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:[self.forumConfig privateWithType:type withPage:page] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (isSuccess) {
            ViewForumPage *page = [self.forumParser parsePrivateMessageFromHtml:html];
            handler(YES, page);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listFavoriteForums:(HandlerWithBool)handler {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:self.forumConfig.usercp parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            NSMutableArray<Forum *> *favForms = [self.forumParser parseFavForumFromHtml:html];
            handler(YES, favForms);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)listFavoriteThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig listfavThreadWithId:page];
    
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {

        if (isSuccess) {
            ViewForumPage *page = [self.forumParser parseFavThreadListFromHtml:html];
            handler(isSuccess, page);
        } else{
            handler(NO, html);
        }
    }];
}

- (void)listNewThreadPostsWithPage:(int)page handler:(HandlerWithBool)handler {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSDate *date = [NSDate date];
    NSInteger timeStamp = [date timeIntervalSince1970];
    
    NSInteger searchId = [userDefault integerForKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
    NSInteger lastTimeStamp = [userDefault integerForKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];
    
    long spaceTime = timeStamp - lastTimeStamp;
    if (page == 1 && (searchId == 0 || spaceTime > 60 * 10)) {
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:self.forumConfig.searchNewThread parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (isSuccess) {
                NSUInteger newThreadPostSearchId = [[self.forumParser parseListMyThreadSearchid:html] integerValue];
                [userDefault setInteger:timeStamp forKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_time"]];
                [userDefault setInteger:newThreadPostSearchId forKey:[self.forumConfig.forumURL.host stringByAppendingString:@"-search_id"]];
            }
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchIdStr = [NSString stringWithFormat:@"%ld", searchId];
        NSString *url = [self.forumConfig searchWithSearchId:searchIdStr withPage:page];
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    }
}

- (void)listTodayNewThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    if (todayNewThreadPostSearchId == nil) {
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:self.forumConfig.searchNewThreadToday parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            
            
            if (isSuccess) {
                todayNewThreadPostSearchId = [self.forumParser parseListMyThreadSearchid:html];
            }
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    } else {
        NSString *url = [self.forumConfig searchWithSearchId:todayNewThreadPostSearchId withPage:page];
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    }
}

- (void)listMyAllThreadPost:(HandlerWithBool)handler {
    LoginUser *user = [self getLoginUser];
    if (user == nil || user.userID == nil) {
        handler(NO, @"未登录");
        return;
    }
    
    NSString *userId = user.userID;
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:[self.forumConfig searchMyPostWithUserId:userId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        handler(isSuccess, html);
    }];
}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {
    LoginUser *user = [self getLoginUser];
    if (user == nil || user.userID == nil) {
        handler(NO, @"未登录");
        return;
    }
    
    if (listMyThreadSearchId == nil) {
        
        NSString *encodeName = [user.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:[self.forumConfig searchMyThreadWithUserName:encodeName] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (listMyThreadSearchId == nil) {
                listMyThreadSearchId = [self.forumParser parseListMyThreadSearchid:html];
            }
            
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    } else {
        NSString *url = [self.forumConfig searchWithSearchId:listMyThreadSearchId withPage:page];
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    }
}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {
    NSString *baseUrl = [self.forumConfig searchThreadWithUserId:[NSString stringWithFormat:@"%d",userId]];
    if (listUserThreadRedirectUrlDictionary == nil || [listUserThreadRedirectUrlDictionary objectForKey:[NSNumber numberWithInt:userId]] == nil) {
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:baseUrl parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (listUserThreadRedirectUrlDictionary == nil) {
                listUserThreadRedirectUrlDictionary = [NSMutableDictionary dictionary];
            }
            
            NSString *searchId = [self.forumParser parseListMyThreadSearchid:html];
            
            [listUserThreadRedirectUrlDictionary setObject:searchId forKey:[NSNumber numberWithInt:userId]];
            
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    } else {
        NSString *searchId = [listUserThreadRedirectUrlDictionary objectForKey:[NSNumber numberWithInt:userId]];
        
        NSString *url = [self.forumConfig searchWithSearchId:searchId withPage:page];
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"3" forKey:@"styleid"];
        [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
            
            if (isSuccess) {
                ViewForumPage *sarchPage = [self.forumParser parseSearchPageFromHtml:html];
                handler(isSuccess, sarchPage);
            } else{
                handler(NO, html);
            }
        }];
    }
}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:[self.forumConfig showThreadWithThreadId:[NSString stringWithFormat:@"%d", threadId] withPage:page] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (html == nil || [html containsString:@"<div style=\"margin: 10px\">没有指定 主题 。如果您来自一个有效链接，请通知<a href=\"sendmessage.php\">管理员</a></div>"] ||
            [html containsString:@"<div style=\"margin: 10px\">沒有指定主題 。如果您來自一個有效連結，請通知<a href=\"sendmessage.php\">管理員</a></div>"] || [html containsString:@"<li>您的账号可能没有足够的权限访问此页面或执行需要授权的操作。</li>"]
            || [html containsString:@"<li>您的帳號可能沒有足夠的權限存取此頁面。您是否正在嘗試編輯別人的文章、存取論壇管理功能或是一些其他需要授權存取的系統?</li>"]){
            handler(NO, @"没有指定主題，可能被删除或无权查看");
            return;
        }
        if (isSuccess) {
            ViewThreadPage *detail = [self.forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showThreadWithP:(NSString *)p handler:(HandlerWithBool)handler {
    NSString *url = [self.forumConfig showThreadWithP:p];
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:url parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (html == nil || [html containsString:@"<div style=\"margin: 10px\">没有指定 主题 。如果您来自一个有效链接，请通知<a href=\"sendmessage.php\">管理员</a></div>"] ||
            [html containsString:@"<div style=\"margin: 10px\">沒有指定主題 。如果您來自一個有效連結，請通知<a href=\"sendmessage.php\">管理員</a></div>"] || [html containsString:@"<li>您的账号可能没有足够的权限访问此页面或执行需要授权的操作。</li>"]
            || [html containsString:@"<li>您的帳號可能沒有足夠的權限存取此頁面。您是否正在嘗試編輯別人的文章、存取論壇管理功能或是一些其他需要授權存取的系統?</li>"]){
            handler(NO, @"没有指定主題，可能被删除或无权查看");
            return;
        }
        if (isSuccess) {
            ViewThreadPage *detail = [self.forumParser parseShowThreadWithHtml:html];
            handler(isSuccess, detail);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:[self.forumConfig forumDisplayWithId:[NSString stringWithFormat:@"%d", forumId] withPage:page] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (isSuccess) {
            ViewForumPage *page = [self.forumParser parseThreadListFromHtml:html withThread:forumId andContainsTop:YES];
            handler(isSuccess, page);
        } else {
            handler(NO, html);
        }
    }];
}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
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
    NSString *searchedUrl = [self.forumConfig searchWithSearchId:searchid withPage:page];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:searchedUrl parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        
        if (isSuccess) {
            
            if ([html containsString:@"对不起，没有匹配记录。请尝试采用其他条件查询。"]) {
                handler(NO, @"对不起，没有匹配记录。请尝试采用其他条件查询。");
            } else if ([html containsString:@"本论坛允许的进行两次搜索的时间间隔必须大于 30 秒。"]){
                handler(NO, @"本论坛允许的进行两次搜索的时间间隔必须大于 30 秒。");
            } else{
                ViewSearchForumPage *page = [self.forumParser parseSearchPageFromHtml:html];
                
                if (page != nil && page.threadList != nil && page.threadList.count > 0) {
                    handler(YES, page);
                } else {
                    handler(NO, @"未知错误");
                }
            }
            
            
        } else {
            handler(NO, html);
        }
    }];
}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:[self.forumConfig memberWithUserId:userId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            UserProfile *profile = [self.forumParser parserProfile:html userId:userId];
            handler(YES, profile);
        } else {
            handler(NO, @"未知错误");
        }
    }];
}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"3" forKey:@"styleid"];
    [self.browser GETWithURLString:[self.forumConfig reportWithPostId:postId] parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
        if (isSuccess) {
            
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"" forKey:@"s"];
            NSString * token = [self.forumParser parseSecurityToken:html];
            [parameters setValue:token forKey:@"securitytoken"];
            [parameters setValue:message forKey:@"reason"];
            [parameters setValue:[NSString stringWithFormat:@"%d", postId] forKey:@"postid"];
            [parameters setValue:@"sendemail" forKey:@"do"];
            [parameters setValue:[NSString stringWithFormat:@"showthread.php?p=%d#post%d", postId, postId] forKey:@"url"];
            
            [self.browser POSTWithURLString:self.forumConfig.report parameters:parameters requestCallback:^(BOOL isSuccess, NSString *html) {
                handler(isSuccess, html);
            }];
        } else {
            handler(NO, html);
        }
    }];
}

- (id <ForumConfigDelegate>)currentConfigDelegate {
    return self.forumConfig;
}


@end

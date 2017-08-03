//
//  CrskyForumHtmlParser.m
//  Forum
//
//  Created by 迪远 王 on 2017/7/29.
//  Copyright © 2017年 andforce. All rights reserved.
//

#import "CrskyForumHtmlParser.h"
#import "IGHTMLDocument.h"
#import "IGHTMLDocument+QueryNode.h"
#import "IGXMLNode+Children.h"
#import "NSString+Extensions.h"

@implementation CrskyForumHtmlParser


// private
- (NSMutableArray<Post *> *)parseShowThreadPosts:(IGHTMLDocument *)document {

    IGXMLNodeSet * postSetNode = [document queryWithClassName:@"t5 t2"];

    NSMutableArray *posts = [NSMutableArray array];

    for (IGXMLNode * postNode in postSetNode) {
        Post * post = [[Post alloc] init];
        // 1. postId
        NSString *pid = [postNode.html stringWithRegular:@"(?<=pid=)\\d+"];
        if (!pid){
            pid = @"tpc";
        }
        post.postID = pid;

        //2. 楼层
        NSString *louceng = [postNode.html stringWithRegular:@"(?<=title=\"复制此楼地址\">)\\d+"];
        if (!louceng){
            louceng = @"楼主";
        }
        post.postLouCeng = louceng;

        IGHTMLDocument *contentDoc = [[IGHTMLDocument alloc] initWithHTMLString:postNode.html error:nil];
        //3. time
        IGXMLNode *timeNode = [contentDoc queryNodeWithClassName:@"fl gray"];
        NSString *time = [timeNode.text.trim stringByReplacingOccurrencesOfString:@"发表于: " withString:@""];
        post.postTime = time;

        //4. content
        IGXMLNode *contentNode = [contentDoc queryNodeWithClassName:@"tpc_content"];
        NSString *content = contentNode.html;
        post.postContent = content;

        //5. user
        User * user = [[User alloc] init];
        //1. userId
        NSString *uid = [postNode.html stringWithRegular:@"(?<=uid=)\\d+"];
        user.userID = uid;
        
        //2. userName
        IGXMLNode *userNameNode = [contentDoc queryNodeWithClassName:@"fl"];
        NSString *uname = userNameNode.text.trim;
        user.userName = uname;
        
        //3. avatar
        IGXMLNode *userAvatarNode = [contentDoc queryNodeWithClassName:@"pic"];
        NSString *avatar = [userAvatarNode attribute:@"src"].trim;
        if (avatar){
            if (![avatar hasPrefix:@"http"]){
                avatar = [@"http://bbs.crsky.com/" stringByAppendingString:avatar];
            }
        }
        user.userAvatar = avatar;
        
        //4. rank
        //5. signDate
        //6. postCount
        //7.forumHost
        post.postUserInfo = user;

        [posts addObject:post];
    }

    return posts;
}

// private
- (NSString *)postMessages:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *postMessages = [document queryWithXPath:@"//*[@id='posts']/div[*]/div/div/div/table/tr[1]/td[2]"];
    NSMutableString *messages = [NSMutableString string];

    for (IGXMLNode *node in postMessages) {
        [messages appendString:node.text];
    }
    return [messages copy];
}

- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];
    //1. tid
    int tid = [[html stringWithRegular:@"(?<=tid=)\\d+"] intValue];
    showThreadPage.threadID = tid;

    //2. fid
    int fid = [[html stringWithRegular:@"(?<=fid=)\\d+"] intValue];
    showThreadPage.forumId = fid;

    //3. title
    IGXMLNode *titleNode = [document queryNodeWithClassName:@"crumbs-item current"];
    NSString *title = titleNode.text.trim;
    showThreadPage.threadTitle = title;

    //4. posts
    NSMutableArray * posts = [self parseShowThreadPosts:document];
    showThreadPage.postList = posts;

    //5. orgHtml
    NSString *orgHtml = [self postMessages:html];
    showThreadPage.originalHtml = orgHtml;

    //6. number
    PageNumber *pageNumber = [self parserPageNumber:html];
    showThreadPage.pageNumber = pageNumber;


    return showThreadPage;
}

// private
- (NSString *)timeForShort:(NSString *)time withFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:time];

    NSTimeInterval intervalTime = date.timeIntervalSinceNow;

    int interval = -intervalTime;
    if (interval < 60) {
        return @"刚刚";
    } else if (interval >= 60 && interval <= 60 * 60) {
        return [NSString stringWithFormat:@"%d分钟前", (int) (interval / 60)];
    } else if (interval > 60 * 60 && interval < 60 * 60 * 24) {
        return [NSString stringWithFormat:@"%d小时前", (int) (interval / (60 * 60))];
    } else if (interval >= 60 * 60 * 24 && interval < 60 * 60 * 24 * 7) {
        return [NSString stringWithFormat:@"%d天前", (int) (interval / (60 * 60 * 24))];
    } else if (interval >= 60 * 60 * 24 * 7 && interval < 60 * 60 * 24 * 30) {
        return [NSString stringWithFormat:@"%d周前", (int) (interval / (60 * 60 * 24 * 7))];
    } else if (interval >= 60 * 60 * 24 * 30 && interval <= 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d月前", (int) (interval / (60 * 60 * 24 * 30))];
    } else if (interval > 60 * 60 * 24 * 365) {
        return [NSString stringWithFormat:@"%d年前", (int) (interval / (60 * 60 * 24 * 365))];
    }

    return time;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *threadNodeSet = [document queryWithClassName:@"tr3 t_one"];

    ViewForumPage *threadListPage = [[ViewForumPage alloc] init];
    NSMutableArray<Thread *> *threads = [NSMutableArray<Thread *> array];

    for (int i = 0; i < threadNodeSet.count; i++) {
        IGXMLNode *threadNode = threadNodeSet[(NSUInteger) i];

        if (threadNode.children.count >= 5) { // 要>=5的原因是：过滤已经被删除的帖子 以及 被移动的帖子

            Thread *thread = [[Thread alloc] init];

            // 1. ID
            NSString *tID = [threadNode.html stringWithRegular:@"(?<=tid=)\\d+"];
            thread.threadID = tID;

            // 2. 标题
            NSString *title = nil;
            // 分类和标题的节点
            IGXMLNode *categoryTitleNode = [threadNode childAt:1];

            NSString *tag = [categoryTitleNode childAt:0].tag;

            if ([tag isEqualToString:@"h3"]){
                // 置顶公告
                title = [categoryTitleNode.text.trim stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
                continue;
            } else if ([tag isEqualToString:@"img"]){
                // 置顶公告
                title = [categoryTitleNode childAt:1].text.trim;
            } else if ([tag isEqualToString:@"a"]){
                // 正常的主题
                NSString *c = [categoryTitleNode childAt:0].text.trim;
                NSString *t = [categoryTitleNode childAt:1].text.trim;
                title = [c stringByAppendingString:t];
            } else {
                NSLog(@"p_title >>>>>>>>>>>>>>>>>>>>>>");
            }

            thread.threadTitle = title;


            NSLog(@"p_title \t%@", title);
            //3 是否是置顶帖子
            BOOL isTop = [categoryTitleNode.html containsString:@"title=\"置顶帖标志\""];
            thread.isTopThread = isTop;

            //4 是否是精华帖子
            BOOL isGoodness = [categoryTitleNode.html containsString:@"title=\"精华帖标志\""];
            thread.isGoodNess = isGoodness;

            //5 是否包含图片
            BOOL isContainsImage = [categoryTitleNode.html containsString:@"file/img.gif"];
            thread.isContainsImage = isContainsImage;

            //6 总回帖页数
            int totalPage = 1;
            BOOL isMoreThanOnePage = [categoryTitleNode.html containsString:@"class=\"tpage\""];
            if (isMoreThanOnePage){
                IGXMLNode * totalPageNode = categoryTitleNode.children[(NSUInteger) (categoryTitleNode.childrenCount -1)];
                IGXMLNode * pageNode = totalPageNode.children[(NSUInteger) (totalPageNode.childrenCount -1)];
                IGXMLNode * numberNode = pageNode.children[(NSUInteger) (pageNode.childrenCount -1)];
                int number = [numberNode.text intValue];
                totalPage = number;
            }
            thread.totalPostPageCount = totalPage;


            IGXMLNode *authorNode = [threadNode childAt:2];
            //7. 帖子作者
            NSString *authorName = [authorNode childAt:0].text.trim;
            thread.threadAuthorName = authorName;

            //8. 作者ID
            NSString *authorId = [[authorNode childAt:0].html stringWithRegular:@"(?<=uid=)\\d+"];
            thread.threadAuthorID = authorId;

            //9. 回复数量
            IGXMLNode *postOpenNode = [threadNode childAt:3];
            NSString * postOpen = postOpenNode.text.trim;
            NSString * postCount = [postOpen componentsSeparatedByString:@"/"][0].trim;
            thread.postCount = postCount;

            //10. 查看数量
            NSString * openCount = [postOpen componentsSeparatedByString:@"/"][1].trim;
            thread.openCount = openCount;

            IGXMLNode *lastPostTimeNode = [threadNode childAt:4];
            //11. 最后回帖时间
            NSString *lastPostTime = [lastPostTimeNode childAt:0].text.trim;
            thread.lastPostTime = lastPostTime;

            //12. 最后发表的人
            NSString *lastPostAuthorName = [[lastPostTimeNode childAt:1].text.trim stringByReplacingOccurrencesOfString:@"by: " withString:@""];
            thread.lastPostAuthorName = lastPostAuthorName;
            
            [threads addObject:thread];
        }
    }
    threadListPage.dataList = threads;

    PageNumber * pageNumber = [self parserPageNumber:html];
    threadListPage.pageNumber = pageNumber;

    return threadListPage;
}


- (ViewForumPage *)parseFavThreadListFromHtml:(NSString *)html {
    return nil;
}

- (NSString *)parseSecurityToken:(NSString *)html {
    return nil;
}

- (NSString *)parsePostHash:(NSString *)html {
    return nil;
}

- (NSString *)parserPostStartTime:(NSString *)html {
    return nil;
}

- (NSString *)parseLoginErrorMessage:(NSString *)html {
    return nil;
}

- (ViewSearchForumPage *)parseSearchPageFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    ViewSearchForumPage *resultPage = [[ViewSearchForumPage alloc] init];
    NSMutableArray<Thread *> *threads = [NSMutableArray array];

    IGXMLNodeSet *searchNodeSet = [document queryWithClassName:@"tr3 tac"];
    
    for (IGXMLNode *threadNode in searchNodeSet) {
        NSString * h = threadNode.html;
        NSLog(@"Scrsky_parser \t%@", h);

        Thread *thread = [[Thread alloc] init];

        // 1. ID
        NSString *tID = [threadNode.html stringWithRegular:@"(?<=tid=)\\d+"];
        thread.threadID = tID;

        // 2. 标题
        // 分类和标题的节点
        IGXMLNode *categoryTitleNode = [threadNode childAt:1];
        NSString *title = [categoryTitleNode.text.trim stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
        thread.threadTitle = title;

        //3 是否是置顶帖子
        BOOL isTop = NO;
        thread.isTopThread = isTop;

        //4 是否是精华帖子
        BOOL isGoodness = NO;
        thread.isGoodNess = isGoodness;

        //5 是否包含图片
        BOOL isContainsImage = NO;
        thread.isContainsImage = isContainsImage;

        //6 总回帖页数
        int totalPage = 1;
        thread.totalPostPageCount = totalPage;

        IGXMLNode *authorNode = [threadNode childAt:3];
        //7. 帖子作者
        NSString *authorName = [authorNode childAt:0].text.trim;
        thread.threadAuthorName = authorName;

        //8. 作者ID
        NSString *authorId = [[authorNode childAt:0].html stringWithRegular:@"(?<=uid=)\\d+"];
        thread.threadAuthorID = authorId;

        //9. 回复数量
        IGXMLNode *postCountNode = [threadNode childAt:4];
        NSString * postCount = postCountNode.text.trim;
        thread.postCount = postCount;

        //10. 查看数量
        IGXMLNode *openCountNode = [threadNode childAt:5];
        NSString * openCount = openCountNode.text.trim;
        thread.openCount = openCount;

        IGXMLNode *lastPostTimeNode = [threadNode childAt:6];
        //11. 最后回帖时间
        NSString *lastPostTime = [lastPostTimeNode childAt:0].text.trim;
        thread.lastPostTime = lastPostTime;

        //12. 最后发表的人
        NSString *lastPostAuthorName = [lastPostTimeNode.text componentsSeparatedByString:@"by: "].lastObject;
        thread.lastPostAuthorName = lastPostAuthorName;

        //13. 所属论坛名称
        IGXMLNode *fourumNmaeNode = [threadNode childAt:2];
        NSString *forumName = fourumNmaeNode.text.trim;
        thread.fromFormName = forumName;

        [threads addObject:thread];
    }

    resultPage.dataList = threads;

    // search id
    NSString *searchId = [html stringWithRegular:@"(?<=sid=)\\d+"];
    resultPage.searchid = searchId;

    // page Number
    resultPage.pageNumber = [self parserPageNumber:html];


    return resultPage;
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    return nil;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSMutableArray<Message *> *messagesList = [NSMutableArray array];

    PageNumber *pageNumber = [self parserPageNumber:html];

    if (type == 0){

        if (pageNumber.currentPageNumber < 2){

            IGXMLNodeSet *systemMessageSet = [document queryWithXPath:@"//*[@id=\"info_public\"]/table/tr[position()>1]"];
            for (IGXMLNode *node in systemMessageSet) {
                long childCount = (long) [[node children] count];
                if (childCount == 5) {
                    // 有4个节点说明是正常的站内短信
                    Message *message = [[Message alloc] init];

                    NSString * msgHtml = node.html;

                    // 1. 是不是未读短信
                    message.isReaded = ![msgHtml containsString:@"class=\"b\""];

                    // 2. 标题
                    IGXMLNode *title = [node childAt:2];
                    message.pmTitle = title.text.trim;

                    // Message Id
                    message.pmID = [msgHtml stringWithRegular:@"(?<=mid=)\\d+"];

                    // 3. 发送PM作者
                    IGXMLNode *author = [node childAt:1];
                    message.pmAuthor = author.text.trim;

                    // 4. 发送者ID
                    message.pmAuthorId = @"-1";

                    // 5. 时间
                    message.pmTime = [node childAt:3].text.trim;

                    [messagesList addObject:message];

                }
            }
        }

        IGXMLNodeSet *privateMessageSet = [document queryWithXPath:@"//*[@id=\"info_base\"]/div[1]/table/tr[position()>2]"];
        for (IGXMLNode *node in privateMessageSet) {
            long childCount = (long) [[node children] count];
            if (childCount == 5) {
                // 有4个节点说明是正常的站内短信
                Message *message = [[Message alloc] init];

                NSString * msgHtml = node.html;

                // 1. 是不是未读短信
                message.isReaded = ![msgHtml containsString:@"class=\"b\""];

                // 2. 标题
                IGXMLNode *title = [node childAt:2];
                message.pmTitle = title.text.trim;

                // Message Id
                message.pmID = [msgHtml stringWithRegular:@"(?<=mid=)\\d+"];

                // 3. 发送PM作者
                IGXMLNode *author = [node childAt:1];
                message.pmAuthor = author.text.trim;

                // 4. 发送者ID
                message.pmAuthorId =[msgHtml stringWithRegular:@"(?<=uid=)\\d+"];

                // 5. 时间
                message.pmTime = [node childAt:3].text.trim;

                [messagesList addObject:message];

            }
        }
    } else{
        IGXMLNodeSet *privateMessageSet = [document queryWithXPath:@"//*[@id=\"info_base\"]/table/tr[position()>1]"];
        for (IGXMLNode *node in privateMessageSet) {
            long childCount = (long) [[node children] count];
            if (childCount == 5) {
                // 有4个节点说明是正常的站内短信
                Message *message = [[Message alloc] init];

                NSString * msgHtml = node.html;

                // 1. 是不是未读短信
                message.isReaded = ![msgHtml containsString:@"class=\"b\""];

                // 2. 标题
                IGXMLNode *title = [node childAt:2];
                message.pmTitle = title.text.trim;

                // Message Id
                message.pmID = [msgHtml stringWithRegular:@"(?<=mid=)\\d+"];

                // 3. 发送PM作者
                IGXMLNode *author = [node childAt:1];
                message.pmAuthor = author.text.trim;

                // 4. 发送者ID
                message.pmAuthorId =[msgHtml stringWithRegular:@"(?<=uid=)\\d+"];

                // 5. 时间
                message.pmTime = [node childAt:3].text.trim;

                [messagesList addObject:message];

            }
        }
    }

    page.pageNumber = [self parserPageNumber:html];
    page.dataList = messagesList;

    return page;
}

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO {
    ViewMessagePage *privateMessage = [[ViewMessagePage alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode * infoBaseNode = [document queryNodeWithXPath:@"//*[@id=\"info_base\"]"];
    // pm ID
    NSString * pmId = [infoBaseNode.html stringWithRegular:@"(?<=mid=)\\d+"];
    privateMessage.pmID = pmId;
    
    // pm Title	
    NSString *pmTitle = [[[infoBaseNode childAt:0] childAt:1] childAt:1].text.trim;
    privateMessage.pmTitle = pmTitle;

    NSString *pmTime = [[[infoBaseNode childAt:0] childAt:2] childAt:1].text.trim;
    privateMessage.pmTime = pmTime;

    NSString *pmContent = [[[infoBaseNode childAt:0] childAt:3] childAt:1].html;
    NSString * content = [NSString stringWithFormat:@"<div style=\"overflow-x: hidden;\">%@</div>", pmContent];
    privateMessage.pmContent = content;

    User *pmAuthor = [[User alloc] init];
    IGXMLNode *authorNode = [[[infoBaseNode childAt:0] childAt:0] childAt:1];
    pmAuthor.userName = authorNode.text.trim;
    pmAuthor.userID = [authorNode.html stringWithRegular:@"(?<=uid=)\\d+"];

    privateMessage.pmUserInfo = pmAuthor;
    return privateMessage;
}

- (NSString *)parseQuickReplyQuoteContent:(NSString *)html {
    return nil;
}

- (NSString *)parseQuickReplyTitle:(NSString *)html {
    return nil;
}

- (NSString *)parseQuickReplyTo:(NSString *)html {
    return nil;
}

- (NSString *)parseUserAvatar:(NSString *)html userId:(NSString *)userId {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *picNode = [document queryNodeWithClassName:@"pic"];
    NSString *src = [picNode attribute:@"src"];
    if ([src hasPrefix:@"http"]){
        return src;
    } else {
        return [@"http://bbs.crsky.com/" stringByAppendingString:src];
    }
}

- (NSString *)parseListMyThreadSearchId:(NSString *)html {
    NSString * sid = [html stringWithRegular:@"(?<=sid=)\\d+"];
    return sid;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    UserProfile *profile = [[UserProfile alloc] init];
    // 用户名
    profile.profileName = [html stringWithRegular:@"(?<=<h1 class=\"u-h1\">)\\S+(?=</h1>)"];

    // 用户等级
    profile.profileRank = [html stringWithRegular:@"(?<=<td class=\"gray3\">等级</td><td>)\\S+(?=</td></tr>)"];

    // 注册日期
    profile.profileRegisterDate = [html stringWithRegular:@"(?<=<td>注册时间 </td> \t\t\t\t\t<th>)\\d+-\\d+-\\d+ \\d+:\\d+:\\d+(?=</th>)"];

    // 最近活动时间
    NSString *lastDay = [html stringWithRegular:@"(?<=<td>最后登录</td> \t\t\t\t\t<th>)\\d+-\\d+-\\d+ \\d+:\\d+:\\d+(?=</th>)"];
    profile.profileRecentLoginDate = lastDay;

    // 帖子总数
    NSString *postCount = [html stringWithRegular:@"(?<=<td>发帖</td> 					<th>)\\d+(?= </th>)"];
    profile.profileTotalPostCount = postCount;


    profile.profileUserId = userId;
    return profile;
}



-(void) ul2Forum:(IGXMLNode *) child parent:(Forum *) parent host:(NSString *) host parentId:(int) parentId{
    IGXMLNodeSet * set = child.children;
    NSMutableArray<Forum *> *childForms = [NSMutableArray array];

    Forum *currentForum = nil;
    for(IGXMLNode * node in set){

        if ([node.html hasPrefix:@"<li>"]){
            currentForum = [[Forum alloc] init];
            NSString * name = [node.text trim];
            currentForum.forumName = name;
            NSString *url = [[node childAt:0] attribute:@"href"];
            int forumId = [[url stringWithRegular:@"f\\d+" andChild:@"\\d+"] intValue];
            currentForum.forumId = forumId;

            currentForum.forumHost = host;
            currentForum.parentForumId = parentId;

            NSLog(@"parserForums>>>>>>>>>>>>>>>>>>>>>+++ \t%@", currentForum.forumName);
            [childForms addObject:currentForum];
        } else if([node.html hasPrefix:@"<ul>"]){
            [self ul2Forum:node parent:currentForum host:host parentId:currentForum.forumId];
        }
    }
    parent.childForums = childForms;
}


- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSString *xPath = @"/html/body/table[2]/tr/td";

    IGXMLNode *contents = [document queryNodeWithXPath:xPath];
    
    int size = contents.childrenCount;

    int replaceId = 10000;
    Forum * current;
    
    NSMutableArray<Forum *> *forms = [NSMutableArray array];
    for (int i = 0; i < size; i++) {
        IGXMLNode * child = [contents childAt:i];

        NSLog(@"parserForums-> %@", child.html);
        if ([child.html hasPrefix:@"<li>"]){
            Forum *parent = [[Forum alloc] init];
            NSString * name = [child.text trim];
            parent.forumName = name;
            parent.forumId = replaceId ++;
            parent.forumHost = host;
            parent.parentForumId = -1;

            current = parent;
            [forms addObject:parent];

        } else if([child.html hasPrefix:@"<ul>"]){

            [self ul2Forum:child parent:current host:host parentId:current.forumId];
        }

    }

    NSMutableArray<Forum *> *needInsert = [NSMutableArray array];

    for (Forum *forum in forms) {
        [needInsert addObjectsFromArray:[self flatForm:forum]];
    }

    NSMutableArray<Forum *> *result = [NSMutableArray array];
    for (Forum *forum in needInsert) {
        if (forum.parentForumId == -1 && forum.childForums == nil){
            continue;
        } else {
            [result addObject:forum];
        }
        NSLog(@"parserForums -----------------> \t%@", forum.forumName);
    }

    return [result copy];
}

- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (PageNumber *)parserPageNumber:(NSString *)html {

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *pageNode = [document queryNodeWithClassName:@"pagesone"];
    NSString *pageStr = [pageNode.text.trim stringByReplacingOccurrencesOfString:@" Go " withString:@""];
    PageNumber * pageNumber = [[PageNumber alloc] init];
    int currentPageNumber = [[pageStr componentsSeparatedByString:@"/"][0] intValue];
    int totalPageNumber = [[pageStr componentsSeparatedByString:@"/"][1] intValue];
    if (currentPageNumber == 0 || totalPageNumber == 0){
        currentPageNumber = 1;
        totalPageNumber = 1;
    }

    pageNumber.currentPageNumber = currentPageNumber;
    pageNumber.totalPageNumber = totalPageNumber;

    return pageNumber;
}


@end

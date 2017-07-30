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

        //3. time
        NSString *time = [postNode.html stringWithRegular:@"(?<=<span class=\"fl gray\" title=\"Array\" style=\"white-space:nowrap;\">发表于: )dddd-dd-dd dd:dd:dd"];
        post.postTime = time;

        //4. content
        IGHTMLDocument *contentDoc = [[IGHTMLDocument alloc] initWithHTMLString:postNode.html error:nil];
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
        NSString * debugHtml = userNameNode.html;
        
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
    PageNumber *pageNumber = [self pageNumber:document];
    showThreadPage.pageNumber = pageNumber;


    return showThreadPage;
}


// private 判断是不是置顶帖子
- (BOOL)isStickyThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/CCFStyle/misc/sticky.gif"];
}

// private 判断是不是精华帖子
- (BOOL)isGoodNessThread:(NSString *)postTitleHtml {
    return [postTitleHtml containsString:@"images/CCFStyle/misc/goodnees.gif"];
}

// private 判断是否包含图片
- (BOOL)isContainsImagesThread:(NSString *)postTitlehtml {
    return [postTitlehtml containsString:@"images/CCFStyle/misc/paperclip.gif"];
}

// private 获取回帖的页数
- (int)threadPostPageCount:(NSString *)postTitlehtml {
    NSArray *postPages = [postTitlehtml arrayWithRegular:@"page=\\d+"];
    if (postPages == nil || postPages.count == 0) {
        return 1;
    } else {
        NSString *countStr = [postPages.lastObject stringWithRegular:@"\\d+"];
        return [countStr intValue];
    }
}

// private
- (NSString *)parseTitle:(NSString *)html {
    NSString *searchText = html;

    NSString *pattern = @"<a href=\"showthread.php\\?t.*";

    NSRange range = [searchText rangeOfString:pattern options:NSRegularExpressionSearch];

    if (range.location != NSNotFound) {
        //NSLog(@"%@", [searchText substringWithRange:range]);
        return [searchText substringWithRange:range];
    }
    return nil;
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
            IGXMLNode *categoryTitleNode = [threadNode childrenAtPosition:1];

            NSString *tag = [categoryTitleNode childrenAtPosition:0].tag;

            if ([tag isEqualToString:@"h3"]){
                // 置顶公告
                title = [categoryTitleNode.text.trim stringByReplacingOccurrencesOfString:@"&nbsp" withString:@""];
                continue;
            } else if ([tag isEqualToString:@"img"]){
                // 置顶公告
                title = [categoryTitleNode childrenAtPosition:1].text.trim;
            } else if ([tag isEqualToString:@"a"]){
                // 正常的主题
                NSString *c = [categoryTitleNode childrenAtPosition:0].text.trim;
                NSString *t = [categoryTitleNode childrenAtPosition:1].text.trim;
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


            IGXMLNode *authorNode = [threadNode childrenAtPosition:2];
            //7. 帖子作者
            NSString *authorName = [authorNode childrenAtPosition:0].text.trim;
            thread.threadAuthorName = authorName;

            //8. 作者ID
            NSString *authorId = [[authorNode childrenAtPosition:0].html stringWithRegular:@"(?<=uid=)\\d+"];
            thread.threadAuthorID = authorId;

            //9. 回复数量
            IGXMLNode *postOpenNode = [threadNode childrenAtPosition:3];
            NSString * postOpen = postOpenNode.text.trim;
            NSString * postCount = [postOpen componentsSeparatedByString:@"/"][0].trim;
            thread.postCount = postCount;

            //10. 查看数量
            NSString * openCount = [postOpen componentsSeparatedByString:@"/"][1].trim;
            thread.openCount = openCount;

            IGXMLNode *lastPostTimeNode = [threadNode childrenAtPosition:4];
            //11. 最后回帖时间
            NSString *lastPostTime = [lastPostTimeNode childrenAtPosition:0].text.trim;
            thread.lastPostTime = lastPostTime;

            //12. 最后发表的人
            NSString *lastPostAuthorName = [[lastPostTimeNode childrenAtPosition:1].text.trim stringByReplacingOccurrencesOfString:@"by: " withString:@""];
            thread.lastPostAuthorName = lastPostAuthorName;
            
            [threads addObject:thread];
        }
    }
    threadListPage.dataList = threads;

    PageNumber * pageNumber = [self pageNumber:document];
    threadListPage.pageNumber = pageNumber;

    return threadListPage;
}

- (PageNumber *) pageNumber:(IGHTMLDocument *) document{
    IGXMLNode *pageNode = [document queryNodeWithClassName:@"pagesone"];
    NSString *pageStr = [pageNode.text.trim stringByReplacingOccurrencesOfString:@" Go " withString:@""];
    PageNumber * pageNumber = [[PageNumber alloc] init];
    int currentPageNumber = [[pageStr componentsSeparatedByString:@"/"][0] intValue];
    int totalPageNumber = [[pageStr componentsSeparatedByString:@"/"][1] intValue];
    pageNumber.currentPageNumber = currentPageNumber;
    pageNumber.totalPageNumber = totalPageNumber;

    return pageNumber;
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

    IGXMLNodeSet *searchNodeSet = [document queryWithClassName:@"tr3 tac"];
    
    for (IGXMLNode *node in searchNodeSet) {
        NSString * h = node.html;
        NSLog(@"Scrsky_parser \t%@", h);
    }

    int count = searchNodeSet.count;

    if (searchNodeSet == nil) {
        return nil;
    }


    ViewSearchForumPage *resultPage = [[ViewSearchForumPage alloc] init];

    IGXMLNode *pageNode = [document queryNodeWithClassName:@"pagesone"];
    NSString * h = pageNode.html;
    NSLog(@"Scrsky_parser >>>>>>>>> \t%@", h);
    
    PageNumber *pageNumber = [[PageNumber alloc] init];
    // 2. 当前页数 和 总页数
    if (pageNode == nil) {
        pageNumber.currentPageNumber = 1;
        pageNumber.totalPageNumber = 1;
    } else {
        pageNumber.currentPageNumber = [[pageNode.text stringWithRegular:@"第 \\d+ 页" andChild:@"\\d+"] intValue];
        pageNumber.totalPageNumber = [[pageNode.text stringWithRegular:@"共 \\d+ 页" andChild:@"\\d+"] intValue];
    }

    NSMutableArray<Thread *> *post = [NSMutableArray array];

    resultPage.searchid = [self parseListMyThreadSearchid:html];
    resultPage.dataList = post;

    return resultPage;
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    return nil;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html forType:(int)type {
    return nil;
}

- (ViewMessagePage *)parsePrivateMessageContent:(NSString *)html avatarBase:(NSString *)avatarBase noavatar:(NSString *)avatarNO {
    return nil;
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

- (NSString *)parseListMyThreadSearchid:(NSString *)html {
    NSString * sid = [html stringWithRegular:@"(?<=sid=)\\d+"];
    return sid;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    return nil;
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
            NSString *url = [[node childrenAtPosition:0] attribute:@"href"];
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
        IGXMLNode * child = [contents childrenAtPosition:i];

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
    return nil;
}


@end

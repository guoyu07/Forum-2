//
// Created by 迪远 王 on 2017/5/6.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import "CHHForumHtmlParser.h"

#import "IGXMLNode+Children.h"

#import "ForumEntry+CoreDataClass.h"
#import "ForumCoreDataManager.h"
#import "NSString+Extensions.h"

#import "IGHTMLDocument+QueryNode.h"
#import "NSUserDefaults+Extensions.h"
#import "AppDelegate.h"

@implementation CHHForumHtmlParser {

}
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {


    IGHTMLDocument * document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    ViewThreadPage *showThreadPage = [[ViewThreadPage alloc] init];
    // threadId
    IGXMLNode * threadIdNode = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]/table[1]/tbody/tr/td[2]/span/a"];
    NSString * threadId = [[threadIdNode attribute:@"href"] componentsSeparatedByString:@"-"][1];
    // threadTitle
    IGXMLNode * threadTitleNode = [document queryNodeWithXPath:@"//*[@id=\"thread_subject\"]"];
    NSString * threadTitle = [[threadTitleNode text] trim];
    // forumId
    IGXMLNode * forumIdNode = [document queryNodeWithXPath:@"//*[@id=\"pt\"]/div/a[4]"];
    NSString * forumId = [[forumIdNode attribute:@"href"] componentsSeparatedByString:@"-"][1];
    // origin html
    NSString * originHtml = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]"].html;
    // totalPageCount
    int  totalPageCount = 1;
    int  currentPage = 1;
    //*[@id="pgt"]/div/div/label/span
    IGXMLNode * totalPageNode = [document queryNodeWithXPath:@"//*[@id=\"pgt\"]/div/div/label/span"];
    if (threadTitleNode != nil){
        totalPageCount = [[[totalPageNode text] stringWithRegular:@"\\d+"] intValue];
        IGXMLNode * currentPageNode = [document queryNodeWithXPath:@"//*[@id=\"pgt\"]/div/div"];
        for (IGXMLNode * node in currentPageNode.children){
            if ([node.html hasPrefix:@"<strong>"] && [node.html hasSuffix:@"</strong>"]){
                currentPage = [[[node text] trim] intValue];
            }
        }
    }

    showThreadPage.threadID = threadId;
    showThreadPage.threadTitle = threadTitle;
    showThreadPage.forumId= forumId;
    showThreadPage.originalHtml;
    showThreadPage.totalPageCount = (NSUInteger) totalPageCount;
    showThreadPage.currentPage = (NSUInteger) currentPage;


    // 回帖列表
    NSMutableArray<Post *> *postList = [NSMutableArray array];

    IGXMLNode * postListNode = [document queryNodeWithXPath:@"//*[@id=\"postlist\"]"];
    for (IGXMLNode * node in postListNode.children){
        NSString * nodeHtml = node.html.trim;
        if ([nodeHtml hasPrefix:@"<div id=\"post_"]){
            Post * post = [[Post alloc] init];
            NSString *postId = [[node attribute:@"id"] componentsSeparatedByString:@"_"][1];
            NSString * loucengQuery = [NSString stringWithFormat: @"//*[@id=\"postnum%@\"]/em", postId];
            IGXMLNode * postLouCengNode = [document queryNodeWithXPath:loucengQuery];
            NSString *postLouCeng = [[postLouCengNode text] trim];
            // 发表时间
            NSString *postTimeQuery = [NSString stringWithFormat:@"//*[@id=\"authorposton%@\"]", postId];
            NSString *postTime = [[document queryNodeWithXPath:postTimeQuery] text];//[[[document queryNodeWithXPath:postTimeQuery] text] stringWithRegular:@"\\d+-\\d+\\d+ \\d+:\\d+"];
            // 发表内容


            NSString *contentQuery = [NSString stringWithFormat:@"//*[@id=\"pid%@\"]/tr[1]/td[2]/div[2]/div/div[1]", postId];
            NSString *postContent = [document queryNodeWithXPath:contentQuery].html;

            // User Info
            User * user = [[User alloc] init];
            // UserId
            NSString * userQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]", postId];
            IGXMLNode * userNode = [document queryNodeWithXPath:userQuery];
            NSString * idNameQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/div[1]/div/a", postId];
            IGXMLNode *idNameNode = [document queryNodeWithXPath:idNameQuery];
            NSString *userId = [[idNameNode attribute:@"href"] stringWithRegular:@"\\d+"];
            NSString * userName = [[idNameNode text] trim];

            NSString * avatarQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/div[3]/div/a/img", postId];
            IGXMLNode * avatarNode = [document queryNodeWithXPath:avatarQuery];
            NSString * avatar = [avatarNode attribute:@"src"];

            NSString * rankQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/p[1]/em/a", postId];
            IGXMLNode *rankNode = [document queryNodeWithXPath:rankQuery];
            NSString *rank = [[rankNode text] trim];

            // 注册日期
            NSString * signQuery = [NSString stringWithFormat:@"//*[@id=\"favatar%@\"]/dl[1]/dd[4]", postId];
            IGXMLNode * signNode = [document queryNodeWithXPath:signQuery];
            NSString * signDate = [signNode text];
            user.userAvatar = avatar;
            user.userID = userId;
            user.userName = userName;
            user.userRank = rank;
            user.userSignDate = signDate;

            post.postContent = postContent;
            post.postID = postId;
            post.postLouCeng = postLouCeng;
            post.postTime = postTime;
            post.postUserInfo = user;

            [postList addObject:post];

        }
    }

    showThreadPage.postList = postList;


    return showThreadPage;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *contents = [document queryNodeWithXPath:@"//*[@id='threadlisttableid']"];
    int childCount = contents.childrenCount;

    for (int i = 0; i < childCount; ++i) {
        IGXMLNode * threadNode = [contents childrenAtPosition:i];
        if (threadNode.childrenCount == 1 && threadNode.firstChild.childrenCount == 5){
            NSString * threadNodeHtml = threadNode.html;
            NSLog(@"%@", threadNodeHtml);

            Thread *thread = [[Thread alloc] init];
            // threadId
            NSString * idAttr = [threadNode attribute:@"id"];
            if (idAttr == nil || ![idAttr containsString:@"_"]) {
                continue;
            }
            NSString * tId = [idAttr componentsSeparatedByString:@"_"][1];
            // thread Title
            IGXMLNode * titleNode = [threadNode.firstChild childrenAtPosition:1];
            NSString * titleHtml = titleNode.html;
            int c = titleNode.childrenCount;
            if (c < 5) {
                continue;
            }

            int titleIndex = 3;
            if (![titleHtml containsString:@"<em>[<a href=\"forum.php?mod=forumdisplay&amp;fid="]) {
                titleIndex = 2;
            }
            NSString *threadTitle = [titleNode childrenAtPosition:titleIndex].text;
            // 作者
            IGXMLNode * authorNode = [threadNode.firstChild childrenAtPosition:2];
            NSString *threadAuthor = [[[authorNode childrenAtPosition:0] text] trim];
            // 作者ID
            NSString *threadAuthorId = [authorNode.innerHtml stringWithRegular:@"space-uid-\\d+" andChild:@"\\d+"];
            //最后发表时间
            IGXMLNode * lastAuthorNode = [threadNode.firstChild childrenAtPosition:4];
            NSString *lastPostTime = [[lastAuthorNode childrenAtPosition:1].text trim];
            // 是否是精华
            // 都不是
            // 是否包含图片
            BOOL isHaveImage = [threadNode.html containsString:@"<img src=\"static/image/filetype/image_s.gif\" alt=\"attach_img\" title=\"图片附件\" align=\"absmiddle\">"];

            // 回复数量
            IGXMLNode * numberNode = [threadNode.firstChild childrenAtPosition:3];
            NSString * huitieShu = numberNode.firstChild.text.trim;
            // 查看数量
            NSString * chakanShu = [[[numberNode childrenAtPosition:1] text] trim];

            // 最后发表的人
            NSString *lastAuthorName = [[lastAuthorNode childrenAtPosition:0].text trim];

            // 帖子回帖页数
            int totalPage = 1;
            if ([titleNode.html containsString:@"<span class=\"tps\">"]){
                IGXMLNode * pageNode = [titleNode childrenAtPosition:titleNode.childrenCount -1];
                NSString * h = [pageNode html];
                if ([[pageNode text] isEqualToString:@"New"]) {
                    pageNode = [titleNode childrenAtPosition:titleNode.childrenCount -2];
                }
                int pageNodeChildCount = pageNode.childrenCount;
                IGXMLNode * realPageNode = [pageNode childrenAtPosition:pageNodeChildCount -1];
                NSString * h1 = [realPageNode html];
                totalPage = [[realPageNode text] intValue];
            }

            // 是否是置顶
            IGXMLNode * iconNode = [threadNode.firstChild childrenAtPosition:0];
            BOOL isPin = [iconNode.html containsString:@"<img src=\"static/image/common/pin"];

            thread.threadID = tId;
            thread.threadTitle = threadTitle;
            thread.threadAuthorName = threadAuthor;
            thread.threadAuthorID = threadAuthorId;
            thread.lastPostTime = lastPostTime;
            thread.isGoodNess = NO;
            thread.isContainsImage = isHaveImage;
            thread.postCount = huitieShu;
            thread.openCount = chakanShu;
            thread.lastPostAuthorName = lastAuthorName;
            thread.totalPostPageCount = totalPage;
            thread.isTopThread = isPin;

            [threadList addObject:thread];
        }
    }

    page.threadList = threadList;

    // 总页数

    IGXMLNode *totalPageNode = [document queryNodeWithXPath:@"//*[@id='fd_page_bottom']/div/label"];
    NSString * totalPageNodeText = totalPageNode.text;


    return page;
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
    ViewSearchForumPage *page = [[ViewSearchForumPage alloc] init];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    //*[@id="threadlist"]/div[2]/table
    IGXMLNode *contents = [document queryNodeWithXPath:@"//*[@id=\"threadlist\"]/div[2]/table"];
    int childCount = contents.childrenCount;

    for (int i = 0; i < childCount; ++i) {
        IGXMLNode * threadNode = [contents childrenAtPosition:i];
        if (threadNode.childrenCount == 1 && threadNode.firstChild.childrenCount == 6){
            NSString * threadNodeHtml = threadNode.html;
            NSLog(@"%@", threadNodeHtml);

            Thread *thread = [[Thread alloc] init];
            // threadId
            NSString * idAttr = [threadNode attribute:@"id"];
            if (idAttr == nil || ![idAttr containsString:@"_"]) {
                continue;
            }
            NSString * tId = [idAttr componentsSeparatedByString:@"_"][1];
            // thread Title
            IGXMLNode * titleNode = [threadNode.firstChild childrenAtPosition:1];
            NSString * titleHtml = titleNode.html;

            int titleIndex = 0;
            NSString *threadTitle = [titleNode childrenAtPosition:titleIndex].text;
            // 作者
            IGXMLNode * authorNode = [threadNode.firstChild childrenAtPosition:3];
            NSString *threadAuthor = [[[authorNode childrenAtPosition:0] text] trim];
            // 作者ID
            NSString *threadAuthorId = [authorNode.innerHtml stringWithRegular:@"space-uid-\\d+" andChild:@"\\d+"];
            //最后发表时间
            IGXMLNode * lastAuthorNode = [threadNode.firstChild childrenAtPosition:5];
            NSString *lastPostTime = [[lastAuthorNode childrenAtPosition:1].text trim];
            // 是否是精华
            // 都不是
            // 是否包含图片
            BOOL isHaveImage = [threadNode.html containsString:@"<img src=\"static/image/filetype/image_s.gif\" alt=\"attach_img\" title=\"图片附件\" align=\"absmiddle\">"];

            // 回复数量
            IGXMLNode * numberNode = [threadNode.firstChild childrenAtPosition:4];
            NSString * huitieShu = numberNode.firstChild.text.trim;
            // 查看数量
            NSString * chakanShu = [[[numberNode childrenAtPosition:1] text] trim];

            // 最后发表的人
            NSString *lastAuthorName = [[lastAuthorNode childrenAtPosition:0].text trim];

            // 帖子回帖页数
            int totalPage = 1;
            if ([titleNode.html containsString:@"<span class=\"tps\">"]){
                IGXMLNode * pageNode = [titleNode childrenAtPosition:titleNode.childrenCount -1];
                NSString * h = [pageNode html];
                if ([[pageNode text] isEqualToString:@"New"]) {
                    pageNode = [titleNode childrenAtPosition:titleNode.childrenCount -2];
                }
                int pageNodeChildCount = pageNode.childrenCount;
                IGXMLNode * realPageNode = [pageNode childrenAtPosition:pageNodeChildCount -1];
                NSString * h1 = [realPageNode html];
                totalPage = [[realPageNode text] intValue];
            }

            thread.threadID = tId;
            thread.threadTitle = threadTitle;
            thread.threadAuthorName = threadAuthor;
            thread.threadAuthorID = threadAuthorId;
            thread.lastPostTime = lastPostTime;
            thread.isGoodNess = NO;
            thread.isContainsImage = isHaveImage;
            thread.postCount = huitieShu;
            thread.openCount = chakanShu;
            thread.lastPostAuthorName = lastAuthorName;
            thread.totalPostPageCount = totalPage;

            [threadList addObject:thread];
        }
    }

    page.threadList = threadList;

    // 总页数

    IGXMLNode *totalPageNode = [document queryNodeWithXPath:@"//*[@id='fd_page_bottom']/div/label"];
    NSString * totalPageNodeText = totalPageNode.text;


    return page;
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    //*[@id="favorite_ul"]
    IGXMLNode * favoriteUl = [document queryNodeWithXPath:@"//*[@id=\"favorite_ul\"]"];
    IGXMLNodeSet * favoriteLis = favoriteUl.children;

    NSMutableArray *ids = [NSMutableArray array];
    
    for (IGXMLNode *favLi in favoriteLis){
        IGXMLNode * forumIdNode = [favLi childrenAtPosition:2];
        NSString * forumIdNodeHtml = forumIdNode.html;
        //<a href="forum-196-1.html" target="_blank">GALAX</a>
        NSString *idsStr = [forumIdNodeHtml stringWithRegular:@"forum-\\d+" andChild:@"\\d+"];
        [ids addObject:@(idsStr.intValue)];
        NSLog(@"%@", forumIdNodeHtml);
    }

    [[NSUserDefaults standardUserDefaults] saveFavFormIds:ids];

    //*[@id="ct"]/div[1]/div[2]/div/div

    // 通过ids 过滤出Form
    ForumCoreDataManager *manager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeForm];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *result = [manager selectData:^NSPredicate * {
        return [NSPredicate predicateWithFormat:@"forumHost = %@ AND forumId IN %@", [NSURL URLWithString:appDelegate.forumBaseUrl].host, ids];
    }];

    NSMutableArray<Forum *> *forms = [NSMutableArray arrayWithCapacity:result.count];

    for (ForumEntry *entry in result) {
        Forum *form = [[Forum alloc] init];
        form.forumName = entry.forumName;
        form.forumId = [entry.forumId intValue];
        [forms addObject:form];
    }
    return forms;
}

- (ViewForumPage *)parsePrivateMessageFromHtml:(NSString *)html {
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
    IGXMLNode *avatarNode = [document queryNodeWithClassName:@"icn avt"];
    NSString *attrSrc = [[avatarNode.firstChild.firstChild attribute:@"src"] stringByReplacingOccurrencesOfString:@"_avatar_small" withString:@"_avatar_middle"];
    return attrSrc;
}

- (NSString *)parseListMyThreadSearchid:(NSString *)html {
    return nil;
}

- (UserProfile *)parserProfile:(NSString *)html userId:(NSString *)userId {
    return nil;
}

- (NSArray<Forum *> *)parserForums:(NSString *)html forumHost:(NSString *)host {
    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    NSMutableArray<Forum *> *forms = [NSMutableArray array];

    NSString *xPath = @"//*[@id='content']";

    IGXMLNode *contents = [document queryNodeWithXPath:xPath];
    int size = contents.childrenCount;

    int replaceId = 10000;
    Forum * current;
    for (int i = 0; i < size; i++) {
        IGXMLNode * child = [contents childrenAtPosition:i];

        NSString * childHtml = child.html;

        if (child.childrenCount == 0){
            Forum *parent = [[Forum alloc] init];
            NSString * name = child.text;
            parent.forumName = name;
            parent.forumId = replaceId;
            replaceId ++;
            parent.forumHost = host;
            parent.parentForumId = -1;

            current = parent;
            [forms addObject:parent];
        } else{
            NSMutableArray<Forum *> *childForms = [NSMutableArray array];
            IGXMLNodeSet * set = child.children;
            for(IGXMLNode * node in set){

                NSString * nodeHtml = node.html;
                Forum *childForum = [[Forum alloc] init];
                NSString * name = node.text;
                childForum.forumName = name;

                NSString *url = [[node childrenAtPosition:0] attribute:@"href"];
                int forumId = [[url stringWithRegular:@"fid-\\d+" andChild:@"\\d+"] intValue];
                childForum.forumId = forumId;
                childForum.forumHost = host;
                childForum.parentForumId = current.forumId;

                [childForms addObject:childForum];
            }

            current.childForums = childForms;

        }

    }

    NSMutableArray<Forum *> *needInsert = [NSMutableArray array];

    for (Forum *forum in forms) {
        [needInsert addObjectsFromArray:[self flatForm:forum]];
    }

    return [needInsert copy];
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

    PageNumber *pageNumber = [[PageNumber alloc] init];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];

    IGXMLNode * pageNode = [document queryNodeWithClassName:@"pg"];

    if (pageNode == nil){
        pageNumber.currentPageNumber = 1;
        pageNumber.totalPageNumber = 1;
    } else{
        IGXMLNodeSet * childNodes = pageNode.children;
        for (IGXMLNode * node in childNodes) {
            NSString * childHtml = node.html;
            if ([childHtml hasPrefix:@"<strong>"] && [childHtml hasSuffix:@"</strong>"]){
                int currentPage = [[[node text] trim] intValue];
                pageNumber.currentPageNumber = currentPage;
                continue;
            }

            if ([childHtml hasPrefix:@"<label>"] && [childHtml hasSuffix:@"</label>"]){
                int totalPage = [[node.text stringWithRegular:@"\\d+"] intValue];
                pageNumber.totalPageNumber = totalPage;
                continue;
            }
        }
    }
    return pageNumber;
}

@end

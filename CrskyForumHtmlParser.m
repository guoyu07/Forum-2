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
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    return nil;
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
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSString *path = [NSString stringWithFormat:@"//*[@id='threadbits_forum_%d']/tr", threadId];

    NSMutableArray<Thread *> *threadList = [NSMutableArray<Thread *> array];

    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNodeSet *contents = [document queryWithXPath:path];

    for (int i = 0; i < contents.count; i++) {
        IGXMLNode *normallThreadNode = contents[(NSUInteger) i];

        if (normallThreadNode.children.count >= 8) { // 要>=8的原因是：过滤已经被删除的帖子 以及 被移动的帖子

            Thread *normalThread = [[Thread alloc] init];

            // 由于各个论坛的帖子格式可能不一样，因此此处的标题等所在的列也会发生变化
            // 需要根据不同的论坛计算不同的位置

            NSInteger childColumnCount = normallThreadNode.children.count;

            int titlePosition = 2;

            if (childColumnCount == 8) {
                titlePosition = 2;
            } else if (childColumnCount == 7) {
                titlePosition = 1;
            }

            // title Node
            IGXMLNode *threadTitleNode = [normallThreadNode childrenAtPosition:titlePosition];

            // title all html
            NSString *titleHtml = [threadTitleNode html];

            // 回帖页数
            normalThread.totalPostPageCount = [self threadPostPageCount:titleHtml];

            // title inner html
            NSString *titleInnerHtml = [threadTitleNode innerHtml];

            // 判断是不是置顶主题
            normalThread.isTopThread = [self isStickyThread:titleHtml];

            // 判断是不是精华帖子
            normalThread.isGoodNess = [self isGoodNessThread:titleHtml];

            // 是否包含小别针
            normalThread.isContainsImage = [self isContainsImagesThread:titleHtml];

            // 主题和分类
            NSString *titleAndCategory = [self parseTitle:titleInnerHtml];
            IGHTMLDocument *titleTemp = [[IGHTMLDocument alloc] initWithXMLString:titleAndCategory error:nil];

            NSString *titleText = [titleTemp text];
            if ([titleText hasPrefix:@"【"]) {
                titleText = [titleText stringByReplacingOccurrencesOfString:@"【" withString:@"["];
                titleText = [titleText stringByReplacingOccurrencesOfString:@"】" withString:@"]"];
            } else {
                titleText = [@"[讨论]" stringByAppendingString:titleText];
            }

            // 分离出主题
            normalThread.threadTitle = titleText;

            //[@"showthread.php?t=" length]    17的由来
            normalThread.threadID = [[titleTemp attribute:@"href"] substringFromIndex:17];

            // 作者相关
            int authorNodePosition = 3;
            if (childColumnCount == 7) {
                authorNodePosition = 2;
            }
            IGXMLNode *authorNode = [normallThreadNode childrenAtPosition:authorNodePosition];
            NSString *authorIdStr = [authorNode innerHtml];
            normalThread.threadAuthorID = [authorIdStr stringWithRegular:@"\\d+"];
            normalThread.threadAuthorName = [authorNode text];

            // 最后回帖时间
            int lastPostTimePosition = 4;
            if (childColumnCount == 7) {
                lastPostTimePosition = 3;
            }
            IGXMLNode *lastPostTime = [normallThreadNode childrenAtPosition:lastPostTimePosition];
            normalThread.lastPostTime = [self timeForShort:[[lastPostTime text] trim] withFormat:@"yyyy-MM-dd HH:mm:ss"];

            // 回帖数量
            int commentCountPosition = 5;
            if (childColumnCount == 7) {
                commentCountPosition = 4;
            }
            IGXMLNode *commentCountNode = [normallThreadNode childrenAtPosition:commentCountPosition];
            normalThread.postCount = [commentCountNode text];

            // 查看数量
            int openCountNodePosition = 6;
            if (childColumnCount == 7) {
                openCountNodePosition = 5;
            }
            IGXMLNode *openCountNode = [normallThreadNode childrenAtPosition:openCountNodePosition];
            normalThread.openCount = [openCountNode text];

            [threadList addObject:normalThread];
        }
    }
    page.dataList = threadList;

    // 总页数
    IGXMLNodeSet *totalPageSet = [document queryWithXPath:@"//*[@id='inlinemodform']/table[4]/tr[1]/td[2]/div/table/tr/td[1]"];
    PageNumber *pageNumber = [[PageNumber alloc] init];
    if (totalPageSet == nil) {
        pageNumber.totalPageNumber = 1;
        pageNumber.currentPageNumber = 1;
    } else {
        IGXMLNode *totalPage = totalPageSet.firstObject;
        NSString *pageText = [totalPage innerHtml];                                             //@"第 1 页，共 4123 页"
        NSString *currentPageText = [pageText componentsSeparatedByString:@"，"].firstObject;   //第 1 页
        NSString *totalPageText = [pageText componentsSeparatedByString:@"，"].lastObject;      //共 4123 页

        pageNumber.totalPageNumber = [[totalPageText stringWithRegular:@"\\d+"] intValue];
        pageNumber.currentPageNumber = [[currentPageText stringWithRegular:@"\\d+"] intValue];
    }
    page.pageNumber = pageNumber;

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
    return nil;
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

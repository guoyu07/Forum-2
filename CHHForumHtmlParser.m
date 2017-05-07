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

@implementation CHHForumHtmlParser {

}
- (ViewThreadPage *)parseShowThreadWithHtml:(NSString *)html {
    return nil;
}

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    ViewForumPage *page = [[ViewForumPage alloc] init];

    NSMutableArray<NormalThread *> *threadList = [NSMutableArray<NormalThread *> array];


    IGHTMLDocument *document = [[IGHTMLDocument alloc] initWithHTMLString:html error:nil];
    IGXMLNode *contents = [document queryNodeWithXPath:@"//*[@id='threadlisttableid']"];
    int childCount = contents.childrenCount;

    for (int i = 0; i < childCount; ++i) {
        IGXMLNode * threadNode = [contents childrenAtPosition:i];
        if (threadNode.childrenCount == 1 && threadNode.firstChild.childrenCount == 5){
            NSString * threadNodeHtml = threadNode.html;
            NSLog(@"%@", threadNodeHtml);

            NormalThread *thread = [[NormalThread alloc] init];
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

            NSString *threadTitle = [titleNode childrenAtPosition:3].text;
            // 作者
            IGXMLNode * authorNode = [threadNode.firstChild childrenAtPosition:2];
            NSString *threadAuthor = [[[authorNode childrenAtPosition:0] text] trim];
            // 作者ID
            NSString *threadAuthorId = [[[authorNode childrenAtPosition:0] attribute:@"href"] stringWithRegular:@"\\d+"];
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
    return nil;
}

- (NSMutableArray<Forum *> *)parseFavForumFromHtml:(NSString *)html {
    return nil;
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
    return nil;
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

@end

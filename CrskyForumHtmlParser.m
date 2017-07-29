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

- (ViewForumPage *)parseThreadListFromHtml:(NSString *)html withThread:(int)threadId andContainsTop:(BOOL)containTop {
    return nil;
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
    return nil;
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

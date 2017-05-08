//
//  ForumCoreDataManager.h
//
//  Created by WDY on 16/1/12.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CoreDataManager.h"
#import "Forum.h"

typedef NS_ENUM(NSInteger, EntryType) {
    EntryTypeForm = 0,
    EntryTypePost,
    EntryTypeUser

};


#pragma mark Form 相关
#define kFormEntry @"ForumEntry"
#define kFormXcda @"forum1"
#define kFormDBName @"forum1.sqlite"

#define kUserEntry @"UserEntry"

@interface ForumCoreDataManager : CoreDataManager

- (instancetype)initWithEntryType:(EntryType)enrty;

- (NSArray<Forum *> *)selectFavForums:(NSArray *)ids;

- (NSArray<Forum *> *)selectChildForumsById:(int)forumId;

- (NSArray<Forum *> *)selectAllForums;

@end

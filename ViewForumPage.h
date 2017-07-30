//
//  ViewForumPage.h
//
//  Created by WDY on 16/3/16.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Thread.h"
#import "PageNumber.h"

@interface ViewForumPage : NSObject

@property(nonatomic, strong) NSMutableArray *dataList;
@property(nonatomic, strong) PageNumber *pageNumber;

@property(nonatomic, assign) BOOL isCanCreateThread;

@end

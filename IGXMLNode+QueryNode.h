//
// Created by WDY on 2016/12/2.
// Copyright (c) 2016 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IGXMLNode.h"

@interface IGXMLNode (QueryNode)

- (IGXMLNode *)queryNodeWithXPath:(NSString *)xpath;

- (IGXMLNode *)queryNodeWithClassName:(NSString *)name;

- (IGXMLNodeSet *)queryWithClassName:(NSString *)name;

@end
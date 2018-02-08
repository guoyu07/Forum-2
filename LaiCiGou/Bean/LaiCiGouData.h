//
//  LaiCiGouData.h
//
//  Created by   on 2018/2/8
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LaiCiGouData : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) BOOL hasData;
@property (nonatomic, assign) double totalCount;
@property (nonatomic, strong) NSArray *petsOnSale;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end

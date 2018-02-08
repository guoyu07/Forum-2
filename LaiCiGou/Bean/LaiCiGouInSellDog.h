//
//  LaiCiGouInSellDog.h
//
//  Created by   on 2018/2/8
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LaiCiGouData;

@interface LaiCiGouInSellDog : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *errorNo;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *errorMsg;
@property (nonatomic, strong) LaiCiGouData *data;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end

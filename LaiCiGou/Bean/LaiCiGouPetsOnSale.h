//
//  LaiCiGouPetsOnSale.h
//
//  Created by   on 2018/2/8
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface LaiCiGouPetsOnSale : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *petsOnSaleIdentifier;
@property (nonatomic, strong) NSString *petUrl;
@property (nonatomic, assign) double generation;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, assign) double rareDegree;
@property (nonatomic, strong) NSString *bgColor;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) double petType;
@property (nonatomic, strong) NSString *petId;
@property (nonatomic, assign) double mutation;
@property (nonatomic, strong) NSString *validCode;
@property (nonatomic, assign) double birthType;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end

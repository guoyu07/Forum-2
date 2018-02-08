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
@property (nonatomic, assign) int generation;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, assign) int rareDegree;
@property (nonatomic, strong) NSString *bgColor;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, assign) int petType;
@property (nonatomic, strong) NSString *petId;
@property (nonatomic, assign) float mutation;
@property (nonatomic, strong) NSString *validCode;
@property (nonatomic, assign) int birthType;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end

//
//  LaiCiGouPetsOnSale.m
//
//  Created by   on 2018/2/8
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "LaiCiGouPetsOnSale.h"


NSString *const kLaiCiGouPetsOnSaleId = @"id";
NSString *const kLaiCiGouPetsOnSalePetUrl = @"petUrl";
NSString *const kLaiCiGouPetsOnSaleGeneration = @"generation";
NSString *const kLaiCiGouPetsOnSaleAmount = @"amount";
NSString *const kLaiCiGouPetsOnSaleRareDegree = @"rareDegree";
NSString *const kLaiCiGouPetsOnSaleBgColor = @"bgColor";
NSString *const kLaiCiGouPetsOnSaleDesc = @"desc";
NSString *const kLaiCiGouPetsOnSalePetType = @"petType";
NSString *const kLaiCiGouPetsOnSalePetId = @"petId";
NSString *const kLaiCiGouPetsOnSaleMutation = @"mutation";
NSString *const kLaiCiGouPetsOnSaleValidCode = @"validCode";
NSString *const kLaiCiGouPetsOnSaleBirthType = @"birthType";


@interface LaiCiGouPetsOnSale ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LaiCiGouPetsOnSale

@synthesize petsOnSaleIdentifier = _petsOnSaleIdentifier;
@synthesize petUrl = _petUrl;
@synthesize generation = _generation;
@synthesize amount = _amount;
@synthesize rareDegree = _rareDegree;
@synthesize bgColor = _bgColor;
@synthesize desc = _desc;
@synthesize petType = _petType;
@synthesize petId = _petId;
@synthesize mutation = _mutation;
@synthesize validCode = _validCode;
@synthesize birthType = _birthType;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.petsOnSaleIdentifier = [self objectOrNilForKey:kLaiCiGouPetsOnSaleId fromDictionary:dict];
            self.petUrl = [self objectOrNilForKey:kLaiCiGouPetsOnSalePetUrl fromDictionary:dict];
            self.generation = [[self objectOrNilForKey:kLaiCiGouPetsOnSaleGeneration fromDictionary:dict] intValue];
            self.amount = [self objectOrNilForKey:kLaiCiGouPetsOnSaleAmount fromDictionary:dict];
            self.rareDegree = [[self objectOrNilForKey:kLaiCiGouPetsOnSaleRareDegree fromDictionary:dict] intValue];
            self.bgColor = [self objectOrNilForKey:kLaiCiGouPetsOnSaleBgColor fromDictionary:dict];
            self.desc = [self objectOrNilForKey:kLaiCiGouPetsOnSaleDesc fromDictionary:dict];
            self.petType = [[self objectOrNilForKey:kLaiCiGouPetsOnSalePetType fromDictionary:dict] intValue];
            self.petId = [self objectOrNilForKey:kLaiCiGouPetsOnSalePetId fromDictionary:dict];
            self.mutation = [[self objectOrNilForKey:kLaiCiGouPetsOnSaleMutation fromDictionary:dict] intValue];
            self.validCode = [self objectOrNilForKey:kLaiCiGouPetsOnSaleValidCode fromDictionary:dict];
            self.birthType = [[self objectOrNilForKey:kLaiCiGouPetsOnSaleBirthType fromDictionary:dict] intValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.petsOnSaleIdentifier forKey:kLaiCiGouPetsOnSaleId];
    [mutableDict setValue:self.petUrl forKey:kLaiCiGouPetsOnSalePetUrl];
    [mutableDict setValue:[NSNumber numberWithInt:self.generation] forKey:kLaiCiGouPetsOnSaleGeneration];
    [mutableDict setValue:self.amount forKey:kLaiCiGouPetsOnSaleAmount];
    [mutableDict setValue:[NSNumber numberWithInt:self.rareDegree] forKey:kLaiCiGouPetsOnSaleRareDegree];
    [mutableDict setValue:self.bgColor forKey:kLaiCiGouPetsOnSaleBgColor];
    [mutableDict setValue:self.desc forKey:kLaiCiGouPetsOnSaleDesc];
    [mutableDict setValue:[NSNumber numberWithInt:self.petType] forKey:kLaiCiGouPetsOnSalePetType];
    [mutableDict setValue:self.petId forKey:kLaiCiGouPetsOnSalePetId];
    [mutableDict setValue:[NSNumber numberWithFloat:self.mutation] forKey:kLaiCiGouPetsOnSaleMutation];
    [mutableDict setValue:self.validCode forKey:kLaiCiGouPetsOnSaleValidCode];
    [mutableDict setValue:[NSNumber numberWithInt:self.birthType] forKey:kLaiCiGouPetsOnSaleBirthType];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.petsOnSaleIdentifier = [aDecoder decodeObjectForKey:kLaiCiGouPetsOnSaleId];
    self.petUrl = [aDecoder decodeObjectForKey:kLaiCiGouPetsOnSalePetUrl];
    self.generation = [aDecoder decodeDoubleForKey:kLaiCiGouPetsOnSaleGeneration];
    self.amount = [aDecoder decodeObjectForKey:kLaiCiGouPetsOnSaleAmount];
    self.rareDegree = [aDecoder decodeDoubleForKey:kLaiCiGouPetsOnSaleRareDegree];
    self.bgColor = [aDecoder decodeObjectForKey:kLaiCiGouPetsOnSaleBgColor];
    self.desc = [aDecoder decodeObjectForKey:kLaiCiGouPetsOnSaleDesc];
    self.petType = [aDecoder decodeDoubleForKey:kLaiCiGouPetsOnSalePetType];
    self.petId = [aDecoder decodeObjectForKey:kLaiCiGouPetsOnSalePetId];
    self.mutation = [aDecoder decodeDoubleForKey:kLaiCiGouPetsOnSaleMutation];
    self.validCode = [aDecoder decodeObjectForKey:kLaiCiGouPetsOnSaleValidCode];
    self.birthType = [aDecoder decodeDoubleForKey:kLaiCiGouPetsOnSaleBirthType];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_petsOnSaleIdentifier forKey:kLaiCiGouPetsOnSaleId];
    [aCoder encodeObject:_petUrl forKey:kLaiCiGouPetsOnSalePetUrl];
    [aCoder encodeDouble:_generation forKey:kLaiCiGouPetsOnSaleGeneration];
    [aCoder encodeObject:_amount forKey:kLaiCiGouPetsOnSaleAmount];
    [aCoder encodeDouble:_rareDegree forKey:kLaiCiGouPetsOnSaleRareDegree];
    [aCoder encodeObject:_bgColor forKey:kLaiCiGouPetsOnSaleBgColor];
    [aCoder encodeObject:_desc forKey:kLaiCiGouPetsOnSaleDesc];
    [aCoder encodeDouble:_petType forKey:kLaiCiGouPetsOnSalePetType];
    [aCoder encodeObject:_petId forKey:kLaiCiGouPetsOnSalePetId];
    [aCoder encodeDouble:_mutation forKey:kLaiCiGouPetsOnSaleMutation];
    [aCoder encodeObject:_validCode forKey:kLaiCiGouPetsOnSaleValidCode];
    [aCoder encodeDouble:_birthType forKey:kLaiCiGouPetsOnSaleBirthType];
}

- (id)copyWithZone:(NSZone *)zone
{
    LaiCiGouPetsOnSale *copy = [[LaiCiGouPetsOnSale alloc] init];
    
    if (copy) {

        copy.petsOnSaleIdentifier = [self.petsOnSaleIdentifier copyWithZone:zone];
        copy.petUrl = [self.petUrl copyWithZone:zone];
        copy.generation = self.generation;
        copy.amount = [self.amount copyWithZone:zone];
        copy.rareDegree = self.rareDegree;
        copy.bgColor = [self.bgColor copyWithZone:zone];
        copy.desc = [self.desc copyWithZone:zone];
        copy.petType = self.petType;
        copy.petId = [self.petId copyWithZone:zone];
        copy.mutation = self.mutation;
        copy.validCode = [self.validCode copyWithZone:zone];
        copy.birthType = self.birthType;
    }
    
    return copy;
}


@end

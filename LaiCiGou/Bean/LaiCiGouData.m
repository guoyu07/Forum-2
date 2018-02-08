//
//  LaiCiGouData.m
//
//  Created by   on 2018/2/8
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "LaiCiGouData.h"
#import "LaiCiGouPetsOnSale.h"


NSString *const kLaiCiGouDataHasData = @"hasData";
NSString *const kLaiCiGouDataTotalCount = @"totalCount";
NSString *const kLaiCiGouDataPetsOnSale = @"petsOnSale";


@interface LaiCiGouData ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LaiCiGouData

@synthesize hasData = _hasData;
@synthesize totalCount = _totalCount;
@synthesize petsOnSale = _petsOnSale;


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
            self.hasData = [[self objectOrNilForKey:kLaiCiGouDataHasData fromDictionary:dict] boolValue];
            self.totalCount = [[self objectOrNilForKey:kLaiCiGouDataTotalCount fromDictionary:dict] doubleValue];
    NSObject *receivedLaiCiGouPetsOnSale = [dict objectForKey:kLaiCiGouDataPetsOnSale];
    NSMutableArray *parsedLaiCiGouPetsOnSale = [NSMutableArray array];
    if ([receivedLaiCiGouPetsOnSale isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedLaiCiGouPetsOnSale) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedLaiCiGouPetsOnSale addObject:[LaiCiGouPetsOnSale modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedLaiCiGouPetsOnSale isKindOfClass:[NSDictionary class]]) {
       [parsedLaiCiGouPetsOnSale addObject:[LaiCiGouPetsOnSale modelObjectWithDictionary:(NSDictionary *)receivedLaiCiGouPetsOnSale]];
    }

    self.petsOnSale = [NSArray arrayWithArray:parsedLaiCiGouPetsOnSale];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.hasData] forKey:kLaiCiGouDataHasData];
    [mutableDict setValue:[NSNumber numberWithDouble:self.totalCount] forKey:kLaiCiGouDataTotalCount];
    NSMutableArray *tempArrayForPetsOnSale = [NSMutableArray array];
    for (NSObject *subArrayObject in self.petsOnSale) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForPetsOnSale addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForPetsOnSale addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForPetsOnSale] forKey:kLaiCiGouDataPetsOnSale];

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

    self.hasData = [aDecoder decodeBoolForKey:kLaiCiGouDataHasData];
    self.totalCount = [aDecoder decodeDoubleForKey:kLaiCiGouDataTotalCount];
    self.petsOnSale = [aDecoder decodeObjectForKey:kLaiCiGouDataPetsOnSale];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_hasData forKey:kLaiCiGouDataHasData];
    [aCoder encodeDouble:_totalCount forKey:kLaiCiGouDataTotalCount];
    [aCoder encodeObject:_petsOnSale forKey:kLaiCiGouDataPetsOnSale];
}

- (id)copyWithZone:(NSZone *)zone
{
    LaiCiGouData *copy = [[LaiCiGouData alloc] init];
    
    if (copy) {

        copy.hasData = self.hasData;
        copy.totalCount = self.totalCount;
        copy.petsOnSale = [self.petsOnSale copyWithZone:zone];
    }
    
    return copy;
}


@end

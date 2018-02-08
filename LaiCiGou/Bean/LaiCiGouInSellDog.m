//
//  LaiCiGouInSellDog.m
//
//  Created by   on 2018/2/8
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "LaiCiGouInSellDog.h"
#import "LaiCiGouData.h"


NSString *const kLaiCiGouInSellDogErrorNo = @"errorNo";
NSString *const kLaiCiGouInSellDogTimestamp = @"timestamp";
NSString *const kLaiCiGouInSellDogErrorMsg = @"errorMsg";
NSString *const kLaiCiGouInSellDogData = @"data";


@interface LaiCiGouInSellDog ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation LaiCiGouInSellDog

@synthesize errorNo = _errorNo;
@synthesize timestamp = _timestamp;
@synthesize errorMsg = _errorMsg;
@synthesize data = _data;


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
            self.errorNo = [self objectOrNilForKey:kLaiCiGouInSellDogErrorNo fromDictionary:dict];
            self.timestamp = [self objectOrNilForKey:kLaiCiGouInSellDogTimestamp fromDictionary:dict];
            self.errorMsg = [self objectOrNilForKey:kLaiCiGouInSellDogErrorMsg fromDictionary:dict];
            self.data = [LaiCiGouData modelObjectWithDictionary:[dict objectForKey:kLaiCiGouInSellDogData]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.errorNo forKey:kLaiCiGouInSellDogErrorNo];
    [mutableDict setValue:self.timestamp forKey:kLaiCiGouInSellDogTimestamp];
    [mutableDict setValue:self.errorMsg forKey:kLaiCiGouInSellDogErrorMsg];
    [mutableDict setValue:[self.data dictionaryRepresentation] forKey:kLaiCiGouInSellDogData];

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

    self.errorNo = [aDecoder decodeObjectForKey:kLaiCiGouInSellDogErrorNo];
    self.timestamp = [aDecoder decodeObjectForKey:kLaiCiGouInSellDogTimestamp];
    self.errorMsg = [aDecoder decodeObjectForKey:kLaiCiGouInSellDogErrorMsg];
    self.data = [aDecoder decodeObjectForKey:kLaiCiGouInSellDogData];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_errorNo forKey:kLaiCiGouInSellDogErrorNo];
    [aCoder encodeObject:_timestamp forKey:kLaiCiGouInSellDogTimestamp];
    [aCoder encodeObject:_errorMsg forKey:kLaiCiGouInSellDogErrorMsg];
    [aCoder encodeObject:_data forKey:kLaiCiGouInSellDogData];
}

- (id)copyWithZone:(NSZone *)zone
{
    LaiCiGouInSellDog *copy = [[LaiCiGouInSellDog alloc] init];
    
    if (copy) {

        copy.errorNo = [self.errorNo copyWithZone:zone];
        copy.timestamp = [self.timestamp copyWithZone:zone];
        copy.errorMsg = [self.errorMsg copyWithZone:zone];
        copy.data = [self.data copyWithZone:zone];
    }
    
    return copy;
}


@end

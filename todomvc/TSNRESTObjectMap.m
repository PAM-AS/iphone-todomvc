//
//  TSNRESTObjectMap.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 06.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNRESTObjectMap.h"

@implementation TSNRESTObjectMap

- (id)initWithClass:(Class)classToInit
{
    self = [self init];
    if(self) {
        self.classToMap = classToInit;
        self.serverPath = [NSStringFromClass(self.class) lowercaseString];
    }
    return(self);
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.objectToWeb = [[NSMutableDictionary alloc] init];
        self.webToObject = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)mapObjectKeys:(NSArray *)objectKeys toWebKeys:(NSArray *)webKeys
{
    for (int i = 0; i < objectKeys.count && i < webKeys.count; i++)
    {
        [self mapObjectKeys:[objectKeys objectAtIndex:i] toWebKeys:[webKeys objectAtIndex:i]];
    }
}

- (void)mapObjectKey:(NSString *)objectKey toWebKey:(NSString *)webKey
{
    
    
    [self.objectToWeb setObject:webKey forKey:objectKey];
    [self.webToObject setObject:objectKey forKey:webKey];
}

- (void)mapObjectKey:(NSString *)objectKey toWebKeys:(NSArray *)webKey
{
    [self.objectToWeb setObject:webKey forKey:objectKey];
    [self.webToObject setObject:objectKey forKey:webKey];
}

-(void)addBoolean:(NSString *)boolean
{
    if (!self.booleans)
        self.booleans = [[NSMutableDictionary alloc] init];
    [self.booleans setObject:@YES forKey:boolean];
}

@end

//
//  TSNRESTObjectMap.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 06.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSNRESTObjectMap : NSObject

@property (nonatomic, strong) Class classToMap;
@property (nonatomic, strong) NSString *serverPath;

@property (nonatomic,strong) NSMutableDictionary *objectToWeb;
@property (nonatomic,strong) NSMutableDictionary *webToObject;
@property (nonatomic,strong) NSMutableDictionary *booleans;

- (id)initWithClass:(Class)classToInit;
- (void)mapObjectKeys:(NSArray *)objectKeys toWebKeys:(NSArray *)webKeys;
- (void)mapObjectKey:(NSString *)objectKey toWebKey:(NSString *)webKey;
- (void)mapObjectKey:(NSString *)objectKey toWebKeys:(NSArray *)webKey;
-(void)addBoolean:(NSString *)boolean;

@end

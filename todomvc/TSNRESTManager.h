//
//  TSNRESTManager.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 06.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSNRESTObjectMap.h"
#import "NSManagedObject+TSNRESTAdditions.h"
#import "Todo.h"

@interface TSNRESTManager : NSObject

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSMutableDictionary *objectMaps;
@property (nonatomic, strong) NSMutableDictionary *customHeaders;

+ (id)sharedManager;

- (void)addObjectMap:(TSNRESTObjectMap *)objectMap;
- (TSNRESTObjectMap *)objectMapForClass:(Class)classToFind;
- (void)setGlobalHeader:(NSString *)header forKey:(NSString *)key;

- (void)persistObject:(id)object;
- (void)deleteObjectFromServer:(id)object;

@end

//
//  Todo.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 05.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Todo : NSManagedObject

@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * systemId;
@property (nonatomic, retain) NSString * title;

@end

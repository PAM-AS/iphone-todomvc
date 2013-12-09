//
//  NSManagedObject+TSNRESTAdditions.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 06.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TSNRESTManager.h"

@interface NSManagedObject (TSNRESTAdditions)

- (void)persist;
- (void)deleteFromServer;

@end

//
//  NSManagedObject+TSNRESTAdditions.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 06.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "NSManagedObject+TSNRESTAdditions.h"

@implementation NSManagedObject (TSNRESTAdditions)

- (void)persist
{
    [[TSNRESTManager sharedManager] persistObject:self];
}

- (void)deleteFromServer
{
    [[TSNRESTManager sharedManager] deleteObjectFromServer:self];
}

@end

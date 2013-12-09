//
//  TSNRESTManager.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 06.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNRESTManager.h"

@implementation TSNRESTManager

+ (id)sharedManager
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (void)addObjectMap:(TSNRESTObjectMap *)objectMap
{
    if (!self.objectMaps)
        self.objectMaps = [[NSMutableDictionary alloc] init];
    [self.objectMaps setObject:objectMap forKey:NSStringFromClass(objectMap.classToMap)];
}

- (void)setGlobalHeader:(NSString *)header forKey:(NSString *)key
{
    if (!self.customHeaders)
        self.customHeaders = [[NSMutableDictionary alloc] init];
    [self.customHeaders setObject:header forKey:key];
}

- (TSNRESTObjectMap *)objectMapForClass:(Class)classToFind
{
    NSLog(@"Finding object map for class %@", NSStringFromClass(classToFind));
    return [self.objectMaps objectForKey:NSStringFromClass(classToFind)];
}

- (void)persistObject:(id)object
{
    NSLog(@"Persisting object %@", object);
    TSNRESTObjectMap *objectMap = [self objectMapForClass:[object class]];
    NSLog(@"ObjectMap: %@", objectMap);
    NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
    [objectMap.objectToWeb enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        // We get the value of the object (the actual data), and set the web key from the objectToWeb dictionary value.
        if ([obj isKindOfClass:[NSString class]])
        {
            if ([object respondsToSelector:NSSelectorFromString(obj)] && [object valueForKey:key])
                [dataDict setObject:[(Todo *)object valueForKey:key] forKey:obj];
        }
        else if ([obj isKindOfClass:[NSArray class]])
        {
            for (NSString *string in obj)
            {
                id objectForKey = [(Todo *)object valueForKey:key];
                if (string && objectForKey)
                    [dataDict setObject:objectForKey forKey:string];
            }
        }
        
        NSLog(@"Adding thing to dict");
        
        // Hack to create bools
        if ([objectMap.booleans objectForKey:key])
            [dataDict setObject:[NSNumber numberWithBool:[[dataDict objectForKey:obj] boolValue]] forKey:obj];
    }];
    
    NSData *JSONData = nil;
    if (dataDict.count > 0)
    {
        NSDictionary *wrapper = [[NSDictionary alloc] initWithObjectsAndKeys:dataDict, [NSStringFromClass([object class]) lowercaseString], nil];
        NSError *error = [[NSError alloc] init];
        JSONData = [NSJSONSerialization dataWithJSONObject:wrapper options:0 error:&error];
        NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
        NSLog(@"Created JSON string from object: %@", JSONString);
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (self.customHeaders)
        [self.customHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request addValue:obj forHTTPHeaderField:key];
        }];
    if (JSONData)
    {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:JSONData];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseURL, objectMap.serverPath]];
    
    if ([[object valueForKey:@"systemId"] boolValue])
        url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", [object valueForKey:@"systemId"]]];
    
    [request setURL:url];
    
    NSLog(@"URL: %@", [[request URL] absoluteString]);
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSLog(@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if ([(NSHTTPURLResponse *)response statusCode] < 200 || [(NSHTTPURLResponse *)response statusCode] > 204)
        {
            NSLog(@"Creation/updated of object failed (Status code %i).", [(NSHTTPURLResponse *)response statusCode]);
            if (error)
                NSLog(@"Error: %@", [error localizedDescription]);
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                id contextObject = [object inContext:localContext];
                [contextObject setDirty:@YES];
            } completion:^(BOOL success, NSError *error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"modelUpdated" object:nil];
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"APIRequestFailed" object:Nil userInfo:@{@"class":NSStringFromClass([object class]), @"object":object, @"response":responseDict}];
        }
        else
        {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                id contextObject = [object inContext:localContext];
                [contextObject setDirty:@NO];
            }];
            NSDictionary *objectData = [responseDict objectForKey:[NSStringFromClass([object class]) lowercaseString]];
            if (objectData) // Only returned by create functions
            {
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    id contextObject = [object inContext:localContext];
                    if (!contextObject)
                        contextObject = [[objectMap classToMap] createInContext:localContext];
                    [contextObject setSystemId:[objectData objectForKey:@"id"]];
                    [objectData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        NSString *objectKey = [[objectMap webToObject] objectForKey:key];
                        if (objectKey && [contextObject respondsToSelector:NSSelectorFromString(objectKey)] && ![objectKey isEqualToString:@"id"])
                            [contextObject setValue:obj forKey:objectKey];
                    }];
                    
                    NSLog(@"Successfully created/updated object. Assigning id %@", [objectData objectForKey:@"id"]);
                    NSLog(@"Object: %@", contextObject);
                } completion:^(BOOL success, NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"modelUpdated" object:nil];
                }];
            }
            else
                NSLog(@"Update successfull");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"APIRequestSucceeded" object:Nil userInfo:@{@"class":NSStringFromClass([object class]), @"object":object, @"response":response}];
        }
    }];
    [dataTask resume];
}

- (void)deleteObjectFromServer:(id)object
{
    TSNRESTObjectMap *objectMap = [self objectMapForClass:[object class]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (self.customHeaders)
        [self.customHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request addValue:object forHTTPHeaderField:key];
        }];
    [request setHTTPMethod:@"DELETE"];
    
    NSNumber *systemId = [object valueForKey:@"systemId"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%@", self.baseURL, objectMap.serverPath, systemId]];
    [request setURL:url];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([(NSHTTPURLResponse *)response statusCode] < 200 || [(NSHTTPURLResponse *)response statusCode] > 204)
        {
            NSLog(@"Creation/updated of object failed (Status code %i).", [(NSHTTPURLResponse *)response statusCode]);
            if (error)
                NSLog(@"Error: %@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"Object successfully deleted.");
        }
    }];
    [dataTask resume];
}

@end

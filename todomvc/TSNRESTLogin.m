//
//  TSNRESTLogin.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNRESTLogin.h"

@implementation TSNRESTLogin

+ (void)loginWithUser:(NSString *)user password:(NSString *)password userClass:(Class)userClass url:(NSString *)url
{
    NSString *postData = [NSString stringWithFormat:@"username_or_email=%@&password=%@&grant_type=password", user, password];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"Login result: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if ([(NSHTTPURLResponse *)response statusCode] < 200 || [(NSHTTPURLResponse *)response statusCode] > 204)
        {
            NSLog(@"Login failed.");
        }
        else
        {
            NSLog(@"Login Succeeded. Proceeding to create user object.");
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSNumber *userId = [dataDict objectForKey:@"user_id"];
            
            if ([dataDict objectForKey:@"access_token"])
                [[TSNRESTManager sharedManager] setGlobalHeader:[NSString stringWithFormat:@"Bearer %@", [dataDict objectForKey:@"access_token"]] forKey:@"Authorization"];
            id user = [userClass createEntity];
            if ([user respondsToSelector:NSSelectorFromString(@"systemId")])
                [user setValue:userId forKey:@"systemId"];
            
            if ([user respondsToSelector:NSSelectorFromString(@"persist")])
            {
                // Equal to [user performSelector:NSSelectorFromString(@"persist") withObject:nil];
                // But without the warning.
                // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
                SEL selector = NSSelectorFromString(@"persist");
                IMP imp = [user methodForSelector:selector];
                void (*func)(id, SEL) = (void *)imp;
                func(user, selector);
            }
        }
    }];
    [dataTask resume];
}

@end

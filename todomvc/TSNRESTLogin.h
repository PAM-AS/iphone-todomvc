//
//  TSNRESTLogin.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSNRESTManager.h"

@interface TSNRESTLogin : NSObject

+ (void)loginWithUser:(NSString *)user password:(NSString *)password userClass:(Class)userClass url:(NSString *)url;

@end

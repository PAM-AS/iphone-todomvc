//
//  TSNLoginViewController.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNRESTManager.h"
#import "User.h"

@interface TSNLoginViewController : UIViewController

- (IBAction)facebookLogin:(id)sender;
- (IBAction)cancel:(id)sender;

@end

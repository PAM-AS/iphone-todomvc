//
//  TSNLoginFormViewController.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNRESTLogin.h"
#import "User.h"

@interface TSNLoginFormViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)login:(id)sender;

@end

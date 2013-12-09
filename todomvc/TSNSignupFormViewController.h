//
//  TSNSignupFormViewController.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAMTextValidator.h"
#import "User.h"
#import "TSNRESTManager.h"

@interface TSNSignupFormViewController : UIViewController <UITextFieldDelegate> {
    float keyboardHeight;
}

@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *usernameField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UITextField *confirmPasswordField;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)signup:(id)sender;

@end

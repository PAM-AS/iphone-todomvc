//
//  TSNSignupFormViewController.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNSignupFormViewController.h"

@interface TSNSignupFormViewController ()

@end

@implementation TSNSignupFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiSucceeded:) name:@"APIRequestSucceeded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiFailed:) name:@"APIRequestFailed" object:nil];
    [self registerForKeyboardNotifications];
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardHeight = kbSize.height;
    [self moveViewForKeyboard];
}

- (void)moveViewForKeyboard
{
    float viewHeight = self.view.frame.size.height;
    float viewBottom = 0.0;
    float keyboardTop = viewHeight-keyboardHeight;
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isFirstResponder])
        {
            viewBottom = subView.frame.origin.y+subView.frame.size.height;
        }
    }
    
    if (keyboardTop < viewBottom)
    {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view setFrame:CGRectMake(0.0, -(viewBottom-keyboardTop), self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
        }];
    }
}

- (IBAction)hideKeyboard:(id)sender
{
    for (UIView *subView in self.view.subviews) {
        if ([subView isFirstResponder])
        {
            [subView resignFirstResponder];
            break;
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self moveViewForKeyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameField)
        [self.emailField becomeFirstResponder];
    else if (textField == self.emailField)
        [self.usernameField becomeFirstResponder];
    else if (textField == self.usernameField)
        [self.passwordField becomeFirstResponder];
    else if (textField == self.passwordField)
        [self.confirmPasswordField becomeFirstResponder];
    else
        [self signup:textField];
    [self moveViewForKeyboard];
    return NO;
}

#pragma mark - IBActions
- (IBAction)signup:(id)sender
{
    // Validate input
    if (self.nameField.text.length < 2)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid name" message:@"You need to enter your name here." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.nameField becomeFirstResponder];
        return;
    }
    
    if (![PAMTextValidator validateEmail:self.emailField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Valid email required" message:@"You need to use a valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.emailField becomeFirstResponder];
        return;
    }
    
    if (self.usernameField.text.length < 2)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid username" message:@"Your username is too short." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.usernameField becomeFirstResponder];
        return;
    }
    
    if (self.passwordField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password required" message:@"You need to set a password at least 6 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.passwordField becomeFirstResponder];
        return;
    }
    
    if (![self.passwordField.text isEqualToString:self.confirmPasswordField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Passwords doesn't match" message:@"The password confirmation didn't match the password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.passwordField becomeFirstResponder];
        return;
    }
    
    [self showLoadingAnimation];
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [User truncateAllInContext:localContext]; // Delete any older users
        
        // Collect data
        User *user = [User createInContext:localContext];
        [user setName:self.nameField.text];
        [user setEmail:self.emailField.text];
        [user setUsername:self.usernameField.text];
        [user setPassword:self.passwordField.text];
        [user setDirty:@YES];
        
        // Send to server
        [user persist];
    }];
}

- (void)apiSucceeded:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome" message:@"User created. Enjoy the app!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
    if ([User findFirst])
    {
        [[TSNRESTManager sharedManager] setGlobalHeader:[NSString stringWithFormat:@"Bearer %@", [[User findFirst] access_token]] forKey:@"Authorization"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)apiFailed:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"User creation failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    });
    [self hideLoadingAnimation];
}

- (void)showLoadingAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicator startAnimating];
        [self.loadingView setHidden:NO];
        [UIView animateWithDuration:0.3 animations:^{
            [self.loadingView setAlpha:1.0];
        }];
    });
}

-(void)hideLoadingAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self.loadingView setAlpha:0.0];
        } completion:^(BOOL finished) {
            [self.loadingIndicator stopAnimating];
            [self.loadingView setHidden:YES];
        }];
    });
}

@end

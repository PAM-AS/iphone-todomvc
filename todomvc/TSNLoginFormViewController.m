//
//  TSNLoginFormViewController.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNLoginFormViewController.h"

@interface TSNLoginFormViewController ()

@end

@implementation TSNLoginFormViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    [self showLoadingAnimation];
    [TSNRESTLogin loginWithUser:self.usernameField.text password:self.passwordField.text userClass:[User class] url:[(NSString *)[[TSNRESTManager sharedManager] baseURL] stringByAppendingPathComponent:@"session"]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField)
        [self.passwordField becomeFirstResponder];
    else
        [self login:textField];
    return NO;
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

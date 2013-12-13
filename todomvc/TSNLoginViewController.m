//
//  TSNLoginViewController.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNLoginViewController.h"

@interface TSNLoginViewController ()

@end

@implementation TSNLoginViewController

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
    
    BOOL facebookInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://requests"]];
    if (facebookInstalled)
        self.fbLoginView.loginBehavior = FBSessionLoginBehaviorWithFallbackToWebView;
    else
        self.fbLoginView.loginBehavior = FBSessionLoginBehaviorUseSystemAccountIfPresent;

    // Set up route, because it's common between all login types.
    TSNRESTObjectMap *userMap = [[TSNRESTObjectMap alloc] initWithClass:[User class]];
    [userMap mapObjectKey:@"name" toWebKey:@"name"];
    [userMap mapObjectKey:@"email" toWebKey:@"email"];
    [userMap mapObjectKey:@"username" toWebKey:@"username"];
    [userMap mapObjectKey:@"password" toWebKeys:@[@"password", @"password_confirmation"]];
    [userMap mapObjectKey:@"access_token" toWebKey:@"access_token"];
    [userMap setServerPath:@"users"];
    [[TSNRESTManager sharedManager] addObjectMap:userMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - FBLoginViewDelegate
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    BOOL isFbLoggedIn = [[FBSession activeSession] isOpen];
    NSLog(@"Is FB logged in? %i", isFbLoggedIn);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome" message:[NSString stringWithFormat:@"Welcome, %@.", [user first_name]] delegate:nil cancelButtonTitle:@"Thanks" otherButtonTitles: nil];
    [alert show];
    
    [self showLoadingAnimation];
    // Send info to server, show waiting animation
    
    
    // [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Facebook Error";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures since they can happen
        // outside of the app. You can inspect the error for more context
        // but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Loading animations
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

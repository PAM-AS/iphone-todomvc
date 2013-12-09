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

#pragma mark - IBActions
- (IBAction)facebookLogin:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not implemented yet" message:@"Try again in next version" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//  TSNLoginViewController.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 09.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TSNRESTManager.h"
#import "User.h"

@interface TSNLoginViewController : UIViewController <FBLoginViewDelegate>

@property (nonatomic, strong) IBOutlet FBLoginView *fbLoginView;
@property (nonatomic, strong) IBOutlet UIView *loadingView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)cancel:(id)sender;

@end

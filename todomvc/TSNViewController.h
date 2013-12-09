//
//  TSNViewController.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 05.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSNTodoCell.h"
#import "User.h"
#import "Todo.h"
#import "TSNRESTManager.h"

@interface TSNViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TSNTodoCellDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *todos;

@property (nonatomic, strong) IBOutlet UIButton *clearAllButton;
@property (nonatomic, strong) IBOutlet UITextField *createTaskTextField;
@property (nonatomic, strong) IBOutlet UITableView *taskTableView;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *leftItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *clearItem;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)loadData;

@end

//
//  TSNTodoCell.h
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 05.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define visibleCheckmark 0.7
#define dimmedCheckmark 0.15

@protocol TSNTodoCellDelegate <NSObject>

@optional
- (void)checkmarkSetTo:(BOOL)done forCell:(UITableViewCell *)cell;
- (void)deleteTodoForCell:(UITableViewCell *)cell;
- (void)editedTodoForCell:(UITableViewCell *)cell;

@end

@interface TSNTodoCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, assign) id <TSNTodoCellDelegate> delegate;

@property (nonatomic,strong) IBOutlet UILabel *todoLabel;
@property (nonatomic,strong) IBOutlet UIButton *checkmarkButton;
@property (nonatomic,strong) IBOutlet UIButton *deleteButton;
@property (nonatomic,strong) IBOutlet UIButton *editButton;
@property (nonatomic,strong) IBOutlet UITextField *editField;

- (IBAction)checkmark:(id)sender;

@end

//
//  TSNTodoCell.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 05.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNTodoCell.h"

@implementation TSNTodoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - IBActions

- (IBAction)checkmark:(id)sender
{
    if (self.checkmarkButton.alpha < 0.3)
    {
        if ([self.delegate respondsToSelector:@selector(checkmarkSetTo:forCell:)])
            [self.delegate checkmarkSetTo:YES forCell:self];
        self.checkmarkButton.alpha = visibleCheckmark;
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(checkmarkSetTo:forCell:)])
            [self.delegate checkmarkSetTo:NO forCell:self];
        self.checkmarkButton.alpha = dimmedCheckmark;
    }
}

- (IBAction)deleteTodo:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(deleteTodoForCell:)])
        [self.delegate deleteTodoForCell:self];
}

- (IBAction)edit:(id)sender
{
    if (!self.editField.inputAccessoryView)
    {
        UIToolbar *inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEditing:)];
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [inputAccessoryView setItems:@[flex, bbi]];
        [[self editField] setInputAccessoryView:inputAccessoryView];
    }
    self.editField.text = self.todoLabel.text;
    self.editField.hidden = NO;
    self.todoLabel.hidden = YES;
    self.editButton.hidden = YES;
    self.deleteButton.hidden = YES;
    [self.editField becomeFirstResponder];
}

- (IBAction)doneEditing:(id)sender
{
    if (self.editField.text.length == 0)
    {
        [self deleteTodo:sender];
        return;
    }
    self.todoLabel.text = self.editField.text;
    [self.editField resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(editedTodoForCell:)])
        [self.delegate editedTodoForCell:self];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.editField.hidden =YES;
    self.todoLabel.hidden = NO;
    self.editButton.hidden = NO;
    self.deleteButton.hidden = NO;
    return YES;
}

@end

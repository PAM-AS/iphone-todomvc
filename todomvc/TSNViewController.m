//
//  TSNViewController.m
//  todomvc
//
//  Created by Thomas Sunde Nielsen on 05.12.13.
//  Copyright (c) 2013 Thomas Sunde Nielsen. All rights reserved.
//

#import "TSNViewController.h"

@interface TSNViewController ()

@end

@implementation TSNViewController

static NSString *CellIdentifier = @"TodoCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    self.clearAllButton.transform = transform;
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self loadData];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [inputAccessoryView setItems:@[flex, bbi]];
    [[self createTaskTextField] setInputAccessoryView:inputAccessoryView];
    
    // Fixes UISegmentedControl bug
    [self.segmentControl setTintColor:[UIColor clearColor]];
    [self.segmentControl setTintColor:self.view.tintColor];
    
    TSNRESTObjectMap *todoMap = [[TSNRESTObjectMap alloc] initWithClass:[Todo class]];
    [todoMap mapObjectKey:@"title" toWebKey:@"title"];
    [todoMap mapObjectKey:@"completed" toWebKey:@"is_completed"];
    [todoMap addBoolean:@"completed"];
    [todoMap setServerPath:@"todos"];
    [[TSNRESTManager sharedManager] addObjectMap:todoMap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelUpdated) name:@"modelUpdated" object:nil];
    
    if ([User findFirst])
    {
        NSLog(@"Current user: %@", [[User findFirst] systemId]);
        [[TSNRESTManager sharedManager] setGlobalHeader:[NSString stringWithFormat:@"Bearer %@", [[User findFirst] access_token]] forKey:@"Authorization"];
    }
    else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"neverUseCloud"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable cloud storage?" message:@"By enabling cloud storage you can access your todos from multiple devices." delegate:self cancelButtonTitle:@"No, not now" otherButtonTitles:@"Yes please", @"No, and never remind me", nil];
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        UIViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateInitialViewController];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }
    else if (buttonIndex == 2)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverUseCloud"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - UIViewController overrides
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load data
- (void)modelUpdated
{
    [self.taskTableView beginUpdates];
    [self loadData];
    [self.taskTableView endUpdates];
}

- (IBAction)loadData
{
    [self loadTodos];
    [[self taskTableView] reloadData];
}

- (void)loadTodos
{
    if (self.segmentControl.selectedSegmentIndex == 0)
        self.todos = [Todo findAllSortedBy:@"systemId" ascending:YES];
    else if (self.segmentControl.selectedSegmentIndex == 1)
        self.todos = [Todo findAllSortedBy:@"systemId" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"completed != 1"]];
    else
        self.todos = [Todo findAllSortedBy:@"systemId" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"completed = 1"]];
    [self.leftItem setTitle:[NSString stringWithFormat:@"%lu left", (unsigned long)[Todo countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"completed != 1"]]]];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self done:textField];
    return NO;
}


#pragma mark - IBActions
- (IBAction)done:(id)sender
{
    if (self.createTaskTextField.text.length > 0)
    {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            Todo *todo = [Todo createInContext:localContext];
            todo.title = self.createTaskTextField.text;
            todo.completed = @NO;
            [todo persist];
        } completion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.createTaskTextField.text = @"";
            });
            [self loadData];
        }];
    }
    [self.createTaskTextField resignFirstResponder];
}

- (IBAction)clear:(id)sender
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:self.todos.count];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        // Add indexpaths to array. Delete afterwards.
        for (Todo *todo in self.todos)
        {
            if ([todo.completed boolValue])
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.todos indexOfObject:todo] inSection:0];
                [indexPaths addObject:indexPath];
            }
        }
        
        // Delete them.
        for (Todo *todo in self.todos)
        {
            if ([todo.completed boolValue])
            {
                Todo *deletableTodo = [todo inContext:localContext];
#warning Delete on server here!
                [deletableTodo deleteInContext:localContext];
            }
        }
    } completion:^(BOOL success, NSError *error) {
        [self.taskTableView beginUpdates];
        [self.taskTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self loadTodos];
        [self.taskTableView endUpdates];
        
    }];
}

- (IBAction)checkAll:(id)sender
{
    BOOL checkTrue = NO;
    if ([Todo countOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"completed != 1"]] > 0)
    {
        checkTrue = YES;
    }
    for (int i = 0; i < self.todos.count; i++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        TSNTodoCell *cell = (TSNTodoCell *)[self.taskTableView cellForRowAtIndexPath:indexPath];
        
        // If checkmark is visually different from what we want, toggle it
        if ([[[self.todos objectAtIndex:i] completed] boolValue] != checkTrue)
            [cell checkmark:nil];
            
        [self checkmarkSetTo:checkTrue forCell:cell];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSNTodoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Todo *todo = [self.todos objectAtIndex:indexPath.row];
    [[cell todoLabel] setText:[todo title]];
    if ([[todo completed] boolValue])
        [[cell checkmarkButton] setAlpha:visibleCheckmark];
    else
        [[cell checkmarkButton] setAlpha:dimmedCheckmark];
    [cell setDelegate:self];
    return cell;
}

#pragma mark - TSNTodoCellDelegate
- (void)checkmarkSetTo:(BOOL)done forCell:(UITableViewCell *)cell
{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSIndexPath *indexPath = [self.taskTableView indexPathForCell:cell];
        Todo *todo = [[self.todos objectAtIndex:indexPath.row] inContext:localContext];
        [todo setCompleted:[NSNumber numberWithBool:done]];
        [todo persist];
    } completion:^(BOOL success, NSError *error) {
        [self loadData];
    }];
}

- (void)deleteTodoForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.taskTableView indexPathForCell:cell];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [[self.todos objectAtIndex:indexPath.row] inContext:localContext];
        [todo deleteFromServer];
        [todo deleteInContext:localContext];
    } completion:^(BOOL success, NSError *error) {
        [self.taskTableView beginUpdates];
        [self.taskTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self loadTodos];
        [self.taskTableView endUpdates];
    }];
}

- (void)editedTodoForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.taskTableView indexPathForCell:cell];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Todo *todo = [[self.todos objectAtIndex:indexPath.row] inContext:localContext];
        todo.title = ((TSNTodoCell *)cell).todoLabel.text;
        [todo persist];
    }];
}

@end

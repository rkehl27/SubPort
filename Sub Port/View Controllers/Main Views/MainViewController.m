//
//  MainViewController.m
//  Sub Port
//
//  Created by School on 2/23/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "CreateAccountTableViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButton:(id)sender {
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    
    [[self navigationController] pushViewController:loginViewController animated:YES];
}

- (IBAction)signUpButton:(id)sender {
//    CreateAccountViewController *createAccountViewController = [[CreateAccountViewController alloc] init];
    
    CreateAccountTableViewController *createAccountViewController = [[CreateAccountTableViewController alloc] init];
    
    [[self navigationController] pushViewController:createAccountViewController animated:YES];
}

@end

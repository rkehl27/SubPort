//
//  SUBSettingsViewController.m
//  Sub Port
//
//  Created by Brandon Michael Kiefer on 4/10/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBSettingsViewController.h"
#import "SUBSelectProvidersTableViewController.h"
#import "VerifiedUser.h"
#import "MainViewController.h"
#import "WebServiceURLBuilder.h"

@interface SUBSettingsViewController ()

@end

@implementation SUBSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self customizeNavigationItem];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeProviders:(id)sender
{
    SUBSelectProvidersTableViewController *selectProvidersViewController = [[SUBSelectProvidersTableViewController alloc] init];
    [[self navigationController] pushViewController:selectProvidersViewController animated:YES];
}

- (IBAction)updateAccount:(id)sender
{
    //do nothing
}

- (IBAction)signOut:(id)sender
{
    NSMutableURLRequest *request = [WebServiceURLBuilder deleteRequestForRouteAppendix:@"sessions"];
  
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Log Out Response: %@", responseString);
    
    [[VerifiedUser sharedUser] resetSharedUser];
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
    
    MainViewController *mainViewController = [[MainViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)customizeNavigationItem
{
    [[self navigationItem] setTitle:@"Settings"];
}

@end

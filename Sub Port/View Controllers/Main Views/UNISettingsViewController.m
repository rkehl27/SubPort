//
//  UNISettingsViewController.m
//  Sub Port
//
//  Created by School on 4/13/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "UNISettingsViewController.h"
#import "VerifiedUser.h"
#import "WebServiceURLBuilder.h"
#import "MainViewController.h"

@interface UNISettingsViewController ()

@end

@implementation UNISettingsViewController

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
    [self customizeNavigationItem];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateAccountInfo:(id)sender
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

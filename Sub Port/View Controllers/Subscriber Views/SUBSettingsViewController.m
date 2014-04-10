//
//  SUBSettingsViewController.m
//  Sub Port
//
//  Created by Brandon Michael Kiefer on 4/10/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBSettingsViewController.h"

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
- (IBAction)changeProviders:(id)sender {
}
- (IBAction)updateAccount:(id)sender {
}
- (IBAction)signOut:(id)sender {
//    NSString *baseLogoutURL = @"http://subportinc.herokuapp.com/api/v1/sessions/?auth_token=";
    
    //NSString *fullLogoutURL = [baseLogoutURL stringByAppendingString:[_user authToken]];
    
//    NSURL *url = [NSURL URLWithString:fullLogoutURL];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"DELETE"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    
//    NSURLResponse *response;
//    NSError *err;
//    
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
//    
//    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"Log Out Response: %@", responseString);
    
    //[_user setEmail:nil];
    //[_user setPassword:nil];
    //[_user setAuthToken:nil];
    
    //fix log out to completely delete user and auth token!
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
}

- (void)customizeNavigationItem
{
    [[self navigationItem] setTitle:@"Settings"];
}

@end

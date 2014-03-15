//
//  LoginViewController.m
//  Sub Port
//
//  Created by School on 2/23/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UIAlertViewDelegate>{
    NSURLConnection *_connection;
    NSMutableData *_jsonData;
}
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginComplete:(id)sender {
    [_user setUsername:[_usernameField text]];
    [_user setPassword:[_passwordField text]];
    
    [self validateUserInformation];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void)validateUserInformation
{
    _jsonData = [[NSMutableData alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://subportinc.herokuapp.com/api/v1/sessions"];

    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    _connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_jsonData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonCheck = [[NSString alloc] initWithData:_jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Json check = %@", jsonCheck);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [av show];
}

@end

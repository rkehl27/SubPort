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
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[self navigationItem] setTitle:@"Login"];
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
    _user = [[VerifiedUser alloc] init];
    [_user setEmail:[_emailField text]];
    [_user setPassword:[_passwordField text]];
    
    [self postUserInformationToServer];
}

- (IBAction)logout:(id)sender {
    NSString *baseLogoutURL = @"http://subportinc.herokuapp.com/api/v1/sessions/?auth_token=";
    
    NSString *fullLogoutURL = [baseLogoutURL stringByAppendingString:[_user authToken]];
    
    NSURL *url = [NSURL URLWithString:fullLogoutURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Log Out Response: %@", responseString);

    [_user setEmail:nil];
    [_user setPassword:nil];
    [_user setAuthToken:nil];
    
    //fix log out to completely delete user and auth token!
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }
}

-(void)postUserInformationToServer
{
    NSDictionary *inputData = @{@"user":@{@"email":[_user email], @"password":[_user password]}};
    
    NSError *error = nil;
    NSData *jsonInputData = [NSJSONSerialization dataWithJSONObject:inputData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:@"http://subportinc.herokuapp.com/api/v1/sessions"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonInputData];

    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Response: %@", responseString);
    
    NSError *localError;
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        [_user setAuthToken:[dataDict objectForKey:@"auth_token"]];
        NSLog(@"Auth Token: %@", [_user authToken]);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:[responseDictionary valueForKey:@"info"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end

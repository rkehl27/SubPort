//
//  LoginViewController.m
//  Sub Port
//
//  Created by School on 2/23/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "SUBMainTableViewController.h"
#import "CMAMainTableViewController.h"
#import "ADMMainTableViewController.h"
#import "ResetPasswordViewController.h"

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
        [_emailField setAccessibilityLabel:@"Email"];
        [_passwordField setAccessibilityLabel:@"Password"];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[self navigationItem] setTitle:@"Login"];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginComplete:(id)sender {
    [[VerifiedUser sharedUser] setEmail:[_emailField text]];
    [[VerifiedUser sharedUser] setPassword:[_passwordField text]];
    
    [self postUserInformationToServer];
}

- (IBAction)forgotSelected:(id)sender {
    ResetPasswordViewController *resetPasswordViewController = [[ResetPasswordViewController alloc] init];
    
    [[self navigationController] pushViewController:resetPasswordViewController animated:YES];
}

- (IBAction)dismissKeyboard:(id)sender
{
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

-(void)postUserInformationToServer
{
    NSDictionary *inputData = @{@"user":@{@"email":[[VerifiedUser sharedUser] email], @"password":[[VerifiedUser sharedUser] password]}};
    
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
        [[VerifiedUser sharedUser] setAuthToken:[dataDict objectForKey:@"auth_token"]];
        [[VerifiedUser sharedUser] setEmail:[_emailField text]];
        
        NSDictionary *userDict = [dataDict objectForKey:@"user"];
        [[VerifiedUser sharedUser] setExpirationDate:[userDict objectForKey:@"expiration_date"]];
        [[VerifiedUser sharedUser] setName:[userDict objectForKey:@"name"]];
        [[VerifiedUser sharedUser] setCsvCode:[userDict objectForKey:@"csc"]];
        [[VerifiedUser sharedUser] setCreditCardNumber:[userDict objectForKey:@"credit_card_number"]];
        
        UITableViewController *mainViewController;
        
        NSLog(@"Content Manager Flag: %@", [dataDict objectForKey:@"content_manager_flag"]);
        NSLog(@"Admin Flag: %@", [dataDict objectForKey:@"admin_flag"]);
        
        if (![[[dataDict objectForKey:@"content_manager_flag"] class] isSubclassOfClass:[NSNull class]]) {
            mainViewController = [[CMAMainTableViewController alloc] init];
        } else if (![[[dataDict objectForKey:@"admin_flag"] class] isSubclassOfClass:[NSNull class]]) {
            mainViewController = [[ADMMainTableViewController alloc] init];
        } else {
            mainViewController = [[SUBMainTableViewController alloc] init];
        }
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
        
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end

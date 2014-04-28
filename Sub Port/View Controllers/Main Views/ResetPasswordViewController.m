//
//  ResetPasswordViewController.m
//  Sub Port
//
//  Created by School on 4/27/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ResetPasswordViewController.h"

@interface ResetPasswordViewController () <UIAlertViewDelegate>{
    NSURLConnection *_connection;
    NSMutableData *_jsonData;
}
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation ResetPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[self navigationItem] setTitle:@"Reset Password"];
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


- (IBAction)resetPressed:(id)sender {
    if ([[_emailField text] length] != 0)
    {
        [self postEmailToServer];
    }
}

-(void)postEmailToServer
{
    NSDictionary *inputData = @{@"email":[_emailField text]};
    
    NSError *error = nil;
    NSData *jsonInputData = [NSJSONSerialization dataWithJSONObject:inputData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:@"http://subportinc.herokuapp.com/api/v1/reset_password"];
    
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
        
        UIAlertView *emailFoundAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:[responseDictionary valueForKey:[NSString stringWithFormat:@"An email has been sent to %@ with a new password", [_emailField text]]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [emailFoundAlertView show];
        
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end

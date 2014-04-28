//
//  ADMSubTypeDetailViewController.m
//  Sub Port
//
//  Created by Rebecca Kehl on 4/27/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMSubTypeDetailViewController.h"
#import "AdminObject.h"
#import "Provider.h"
#import "WebServiceURLBuilder.h"

@interface ADMSubTypeDetailViewController (){
    AdminObject *_adminObject;
    Provider *_providerObj;
}

@end

@implementation ADMSubTypeDetailViewController

- (id)initWithAdminObject:(AdminObject *)administratorObj AndProvider:(Provider *)provider
{
    self = [super init];
    if (self) {
        _adminObject = administratorObj;
        _providerObj = provider;
    }
    return self;
}

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
    [self customizeNavigationBar];
    
    NSString *labelString = [NSString stringWithFormat:@"New %@ Type", [_adminObject objectType]];
    
    [[self objectLabel] setText:labelString];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Connection Information

- (IBAction)cancelButtonPressed:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:[self dismissBlock]];
}

- (IBAction)done:(id)sender
{
    if ([self validateObject]) {
        [self addAdminObjectType];
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:[self dismissBlock]];
    } else {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your new type needs a name!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [av show];
    }
}

- (BOOL)validateObject
{
    if ([[[self objectTextField] text] length] > 0) {
        return true;
    } else {
        return false;
    }
}

- (void)addAdminObjectType
{
    NSDictionary *postDict = @{@"name":[[self objectTextField] text],
                               @"provider_id":[_providerObj idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder putRequestForRouteAppendix:[_adminObject routeAppendix] withDictionary:postDict];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self addConnectionDidFinishWithData:responseData orError:err];
}

- (void)addConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        // NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

#pragma mark - Navigation Control

- (void)customizeNavigationBar
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
}
@end

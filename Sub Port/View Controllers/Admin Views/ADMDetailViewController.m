//
//  ADMDetailViewController.m
//  Sub Port
//
//  Created by Rebecca Kehl on 4/26/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMDetailViewController.h"
#import "AdminObject.h"
#import "WebServiceURLBuilder.h"

@interface ADMDetailViewController () {
    AdminObject *_adminObject;
}

@end

@implementation ADMDetailViewController

- (id)initWithAdminObject:(AdminObject *)administratorObj
{
    self = [super init];
    if (self) {
        _adminObject = administratorObj;
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

- (IBAction)done:(id)sender
{
    [self addAdminObjectType];
    NSLog(@"Submitted");
}

- (void)addAdminObjectType
{
    NSDictionary *postDict = @{@"name":[[self textField] text]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDict forRouteAppendix:[_adminObject routeAppendix]];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self addConnectionDidFinishWithData:responseData orError:err];
}

- (void)addConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
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
    //NSString *titleString = [NSString stringWithFormat:@"Add %@", [_adminObject objectType]];
    //[[self navigationItem] setTitle:titleString];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
}

@end

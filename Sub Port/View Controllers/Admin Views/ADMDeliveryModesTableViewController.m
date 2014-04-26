//
//  ADMDeliveryModesTableViewController.m
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMDeliveryModesTableViewController.h"
#import "ADMDetailViewController.h"
#import "DeliveryMode.h"
#import "WebServiceURLBuilder.h"

@interface ADMDeliveryModesTableViewController () {
    NSMutableArray *_deliveryModes;
}

@end

@implementation ADMDeliveryModesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _deliveryModes = [[NSMutableArray alloc] init];
        [self customizeNavigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchDeliveryModesInBackground];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_deliveryModes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    DeliveryMode *deliveryModeInstance = [self deliveryModeAtIndexPath:indexPath];
    [[cell textLabel]setText:[deliveryModeInstance deliveryModeName]];
    
    return cell;
}

- (DeliveryMode *)deliveryModeAtIndexPath:(NSIndexPath *)indexPath
{
    return [_deliveryModes objectAtIndex:[indexPath row]];
}

#pragma mark - Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeliveryMode *modeToDelete = [_deliveryModes objectAtIndex:[indexPath row]];
    
    [_deliveryModes removeObjectAtIndex:[indexPath row]];
    [self deleteDeliveryMode:modeToDelete];
    
    NSLog(@"Deleted row.");
}

#pragma mark - Connection Information

- (void)fetchDeliveryModesInBackground
{
    [_deliveryModes removeAllObjects];
    NSMutableURLRequest *request = [WebServiceURLBuilder getRequestForRouteAppendix:@"delivery_modes"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        NSDictionary *deliveryModes = [dataDict objectForKey:@"delivery_modes"];
        
        for (NSDictionary *deliveryModeDictionary in deliveryModes) {
            DeliveryMode *currentDeliveryMode = [[DeliveryMode alloc] init];
            [currentDeliveryMode setIdNumber:[deliveryModeDictionary objectForKey:@"id"]];
            [currentDeliveryMode setDeliveryModeName:[deliveryModeDictionary objectForKey:@"name"]];
            [_deliveryModes addObject:currentDeliveryMode];
        }
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}

- (void)deleteDeliveryMode:(DeliveryMode *)modeToDelete
{
    NSDictionary *deleteDict = @{@"id":[modeToDelete idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder deleteRequestForRouteAppendix:@"delivery_modes" withDictionary:deleteDict];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self deleteConnectionDidFinishWithData:responseData orError:err];
}

- (void)deleteConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}

#pragma mark - Navigation Item Configuration

- (IBAction)addDeliveryMode:(id)sender
{
    AdminObject *adminObj = [[AdminObject alloc] initWithObjectType:@"Delivery Mode" andRouteAppendix:@"delivery_modes"];
    
    ADMDetailViewController *detailView = [[ADMDetailViewController alloc] initWithAdminObject:adminObj];
    [[self navigationController] pushViewController:detailView animated:YES];
}

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:@"Delivery Modes List"];
    
    UIBarButtonItem *addDeliveryModeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDeliveryMode:)];
    [[self navigationItem] setRightBarButtonItem:addDeliveryModeButton];
}

@end
//
//  ADMDeliveryModesTableViewController.m
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMDeliveryModesTableViewController.h"
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
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (DeliveryMode *)deliveryModeAtIndexPath:(NSIndexPath *)indexPath
{
    return [_deliveryModes objectAtIndex:[indexPath row]];
}

#pragma mark - Connection Information

- (void)fetchDeliveryModesInBackground
{
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

#pragma mark - Navigation Item Configuration

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:@"Delivery Modes List"];
}

@end
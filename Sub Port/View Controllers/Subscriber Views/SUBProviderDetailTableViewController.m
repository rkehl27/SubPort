//
//  SUBProviderDetailTableViewController.m
//  Sub Port
//
//  Created by School on 4/11/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "SUBProviderDetailTableViewController.h"
#import "WebServiceURLBuilder.h"
#import "DetailRow.h"

@interface SUBProviderDetailTableViewController () {
    Provider *_provider;
    NSString *_contentArea;
    NSString *_deliveryMode;
    NSArray *_subscriptionTypes;
    
    NSMutableArray *_rows;
}

@end

@implementation SUBProviderDetailTableViewController

- (id)initWithProvider:(Provider *)provider
{
    self = [self initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _provider = provider;
        _rows = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchProviderDetails];

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
    return [_rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *cellIdentifier = @"cellIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    if ([indexPath row] == 2) {
//        [[cell textLabel] setText:@"Type"];
//    }
//
    DetailRow *row = [_rows objectAtIndex:[indexPath row]];

    UITableViewCell *cell = [[row cellForDetailRow] copy];
    
    return cell;
}

#pragma mark - Connection Information

- (void)fetchProviderDetails
{
    NSDictionary *inputData = @{@"id":[_provider idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:inputData forRouteAppendix:@"sub_providers"];
    
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
        _subscriptionTypes = [dataDict objectForKey:@"subscriptions"];
        _contentArea = [dataDict objectForKey:@"content_area"];
        _deliveryMode = [dataDict objectForKey:@"delivery_mode"];
        
        DetailRow *contentAreaRow = [[DetailRow alloc] init];
        [contentAreaRow setLeftLabel:@"Content Area"];
        [contentAreaRow setRightLabel:_contentArea];
        
        DetailRow *deliveryModeRow = [[DetailRow alloc] init];
        [deliveryModeRow setLeftLabel:@"Delivery Mode"];
        [deliveryModeRow setRightLabel:_deliveryMode];
        
        DetailRow *subscriptionTypeRow = [[DetailRow alloc] init];
        [subscriptionTypeRow setLeftLabel:@"Type"];
        
        [_rows addObject:contentAreaRow];
        [_rows addObject:deliveryModeRow];
        [_rows addObject:subscriptionTypeRow];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}

@end

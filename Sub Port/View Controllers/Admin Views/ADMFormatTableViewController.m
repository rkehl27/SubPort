//
//  ADMFormatTableViewController.m
//  Sub Port
//
//  Created by Brandon Michael Kiefer on 4/24/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMFormatTableViewController.h"
#import "WebServiceURLBuilder.h"
//#import "FormatType.h"

@interface ADMFormatTableViewController () {
    NSMutableArray *_formatTypes;
}

@end

@implementation ADMFormatTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _formatTypes = [[NSMutableArray alloc] init];
        [self customizeNavigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchFormatsInBackground];
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
    return [_formatTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    //FormatType *formatInstance = [self providerAtIndexPath:indexPath];
    //[[cell textLabel]setText:[formatInstance providerName]];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

//- (FormatType *)providerAtIndexPath:(NSIndexPath *)indexPath
//{
//    return [_formatTypes objectAtIndex:[indexPath row]];
//}

#pragma mark - Connection Information

- (void)fetchFormatsInBackground
{
    NSMutableURLRequest *request = [WebServiceURLBuilder getRequestForRouteAppendix:@"formats"];
    
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
//        NSDictionary *providers = [dataDict objectForKey:@"providers"];
//        
//        for (NSDictionary *providerDictionary in providers) {
//            Provider *currentProvider = [[Provider alloc] init];
//            [currentProvider setIdNumber:[providerDictionary objectForKey:@"id"]];
//            [currentProvider setProviderName:[providerDictionary objectForKey:@"name"]];
//            [_providers addObject:currentProvider];
//        }
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}

#pragma mark - Navigation Item Configuration

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:@"Formats List"];
}

@end

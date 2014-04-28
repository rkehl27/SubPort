//
//  ADMProvidersTableViewController.m
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMProvidersTableViewController.h"
#import "Provider.h"
#import "WebServiceURLBuilder.h"

@interface ADMProvidersTableViewController () {
    NSMutableArray *_providers;
}

@end

@implementation ADMProvidersTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _providers = [[NSMutableArray alloc] init];
        [self customizeNavigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchProvidersInBackground];
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
    return [_providers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Provider *providerInstance = [self providerAtIndexPath:indexPath];
    [[cell textLabel]setText:[providerInstance providerName]];
        
    return cell;
}

- (Provider *)providerAtIndexPath:(NSIndexPath *)indexPath
{
    return [_providers objectAtIndex:[indexPath row]];
}

#pragma mark - Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    NSLog(@"Deleted row.");
}

#pragma mark - Connection Information

- (void)fetchProvidersInBackground
{
    NSMutableURLRequest *request = [WebServiceURLBuilder getRequestForRouteAppendix:@"providers"];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self connectionDidFinishWithData:responseData orError:err];
}

- (void)connectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        NSDictionary *providers = [dataDict objectForKey:@"providers"];
        
        for (NSDictionary *providerDictionary in providers) {
            Provider *currentProvider = [[Provider alloc] init];
            [currentProvider setIdNumber:[providerDictionary objectForKey:@"id"]];
            [currentProvider setProviderName:[providerDictionary objectForKey:@"name"]];
            [_providers addObject:currentProvider];
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
    [[self navigationItem] setTitle:@"Providers List"];
}

@end

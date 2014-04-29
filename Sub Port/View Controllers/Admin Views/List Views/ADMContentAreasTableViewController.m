//
//  ADMContentAreasTableViewController.m
//  Sub Port
//
//  Created by School on 4/14/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMContentAreasTableViewController.h"
#import "ADMDetailViewController.h"
#import "AdminObject.h"
#import "ContentArea.h"
#import "WebServiceURLBuilder.h"

@interface ADMContentAreasTableViewController () {
    NSMutableArray *_contentAreas;
}

@end

@implementation ADMContentAreasTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _contentAreas = [[NSMutableArray alloc] init];
        [self customizeNavigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchContentAreasInBackground];
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
    return [_contentAreas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ContentArea *contentAreaInstance = [self contentAreaAtIndexPath:indexPath];
    [[cell textLabel]setText:[contentAreaInstance contentAreaName]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    cell.accessoryView = switchView;
    if ([contentAreaInstance isHidden]) {
        [switchView setOn:NO animated:NO];
    }
    else {
        [switchView setOn:YES animated:NO];
    }
    [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    UIView* contentView = [switchControl superview];
    UITableViewCell* cell = (UITableViewCell *)[contentView superview];
    
    for (ContentArea *tempContentArea in _contentAreas) {
        if ([tempContentArea contentAreaName] == cell.textLabel.text) {
            NSDictionary *postDictionary = @{@"id":[tempContentArea idNumber]};
            NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDictionary forRouteAppendix:@"hide_content_areas"];
            
            NSURLResponse *response;
            NSError *err;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            
            [self connectionDidFinishWithDataAfterPost:responseData orError:err];
        }
    }
    
}

- (ContentArea *)contentAreaAtIndexPath:(NSIndexPath *)indexPath
{
    return [_contentAreas objectAtIndex:[indexPath row]];
}

#pragma mark - Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentArea *areaToDelete = [_contentAreas objectAtIndex:[indexPath row]];
    
    [_contentAreas removeObjectAtIndex:[indexPath row]];
    [self deleteContentArea:areaToDelete];
}

#pragma mark - Connection Information

- (void)fetchContentAreasInBackground
{
    [_contentAreas removeAllObjects];
    NSMutableURLRequest *request = [WebServiceURLBuilder getRequestForRouteAppendix:@"content_areas"];
    
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
        NSDictionary *contentAreas = [dataDict objectForKey:@"content_areas"];
        
        for (NSDictionary *contentAreaDictionary in contentAreas) {
            ContentArea *currentContentArea = [[ContentArea alloc] init];
            [currentContentArea setIdNumber:[contentAreaDictionary objectForKey:@"id"]];
            [currentContentArea setContentAreaName:[contentAreaDictionary objectForKey:@"name"]];
            if([[[contentAreaDictionary objectForKey:@"hidden_flag"] class] isSubclassOfClass:[NSNull class]])
            {
                [currentContentArea setIsHidden:NO];
            } else {
                [currentContentArea setIsHidden:YES];
            }

            [_contentAreas addObject:currentContentArea];
        }
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}

- (void)connectionDidFinishWithDataAfterPost:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
}


- (void)deleteContentArea:(ContentArea *)areaToDelete
{
    NSDictionary *deleteDict = @{@"id":[areaToDelete idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder deleteRequestForRouteAppendix:@"content_areas" withDictionary:deleteDict];
    
    NSURLResponse *response;
    NSError *err;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    [self deleteConnectionDidFinishWithData:responseData orError:err];
}

- (void)deleteConnectionDidFinishWithData:(NSData *)responseData orError:(NSError *)error
{
    NSError *localError;
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
//        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}

#pragma mark - Navigation Item Configuration

- (IBAction)addContentArea:(id)sender
{
    AdminObject *adminObj = [[AdminObject alloc] initWithObjectType:@"Content Area" andRouteAppendix:@"content_areas"];
    
    ADMDetailViewController *detailView = [[ADMDetailViewController alloc] initWithAdminObject:adminObj];
    
    detailView.dismissBlock = ^{
        [self fetchContentAreasInBackground];
    };
    
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
    
    [self presentViewController:navControl animated:YES completion:nil];
}

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:@"Content Areas List"];
    
    UIBarButtonItem *addContentButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContentArea:)];
    [[self navigationItem] setRightBarButtonItem:addContentButton];
}

@end
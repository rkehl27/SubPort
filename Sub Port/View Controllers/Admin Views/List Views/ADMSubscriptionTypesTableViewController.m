//
//  ADMSubscriptionTypesTableViewController.m
//  Sub Port
//
//  Created by Rebecca Kehl on 4/26/14.
//  Copyright (c) 2014 Sub Port Inc. All rights reserved.
//

#import "ADMSubscriptionTypesTableViewController.h"
#import "ADMSubTypeDetailViewController.h"
#import "WebServiceURLBuilder.h"
#import "SubscriptionType.h"
#import "Provider.h"
#import "AdminObject.h"

@interface ADMSubscriptionTypesTableViewController () {
    NSMutableArray *_subscriptionTypes;
    Provider *_selectedProvider;
}

@end

@implementation ADMSubscriptionTypesTableViewController

- (id)initWithProvider:(Provider *)associatedProvider
{
    self = [super init];
    if (self) {
        _selectedProvider = associatedProvider;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _subscriptionTypes = [[NSMutableArray alloc] init];
        [self customizeNavigationBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchSubTypesInBackground];
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
    return [_subscriptionTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    SubscriptionType *subTypeInstance = [self subTypeAtIndexPath:indexPath];
    [[cell textLabel]setText:[subTypeInstance subscriberName]];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    cell.accessoryView = switchView;
    if ([subTypeInstance isHidden]) {
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
    
    for (SubscriptionType *tempSubType in _subscriptionTypes) {
        if ([tempSubType subscriberName] == cell.textLabel.text) {
            NSDictionary *postDictionary = @{@"id":[tempSubType idNumber]};
            NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:postDictionary forRouteAppendix:@"hide_subscriptions"];
            
            NSURLResponse *response;
            NSError *err;
            
            NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
            
            [self connectionDidFinishWithDataAfterPost:responseData orError:err];
        }
    }
    
}

- (SubscriptionType *)subTypeAtIndexPath:(NSIndexPath *)indexPath
{
    return [_subscriptionTypes objectAtIndex:[indexPath row]];
}

#pragma mark - Swipe to Delete

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    SubscriptionType *modeToDelete = [_subscriptionTypes objectAtIndex:[indexPath row]];
    
    [_subscriptionTypes removeObjectAtIndex:[indexPath row]];
    [self deleteSubType:modeToDelete];
    
    NSLog(@"Deleted row.");
}

#pragma mark - Connection Information

- (void)fetchSubTypesInBackground
{
    [_subscriptionTypes removeAllObjects];
    
    NSDictionary *_postDict = @{@"id":[_selectedProvider idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder postRequestWithDictionary:_postDict forRouteAppendix:@"subscriptions"];
    
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

        NSArray *typesOfSubscriptions = [dataDict objectForKey:@"subscriptions"];

        for (NSDictionary *typeOfSubscriptionDict in typesOfSubscriptions) {
            SubscriptionType *subscriptionTypeInst = [[SubscriptionType alloc] init];
            [subscriptionTypeInst setSubscriberName:[typeOfSubscriptionDict objectForKey:@"name"]];
            [subscriptionTypeInst setIdNumber:[typeOfSubscriptionDict objectForKey:@"id"]];
            [subscriptionTypeInst setAssociatedProvider:_selectedProvider];

            if([[[typeOfSubscriptionDict objectForKey:@"hidden_flag"] class] isSubclassOfClass:[NSNull class]])
            {
                [subscriptionTypeInst setIsHidden:NO];
            } else {
                [subscriptionTypeInst setIsHidden:YES];
            }
            
            [_subscriptionTypes addObject:subscriptionTypeInst];
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
    NSLog(@"Response: %@", responseString);
    
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&localError];
    
    if ([responseDictionary valueForKey:@"success"]) {
//        NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
}

- (void)deleteSubType:(SubscriptionType *)modeToDelete
{
    NSDictionary *deleteDict = @{@"sub_id":[modeToDelete idNumber]};
    
    NSMutableURLRequest *request = [WebServiceURLBuilder deleteRequestForRouteAppendix:@"subscriptions" withDictionary:deleteDict];
    
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
        //NSDictionary *dataDict = [responseDictionary objectForKey:@"data"];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[responseDictionary valueForKey:@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
    }
    
    [[self tableView] reloadData];
}

#pragma mark - Navigation Item Configuration

- (IBAction)addSubType:(id)sender
{
    AdminObject *adminObj = [[AdminObject alloc] initWithObjectType:@"Subscription" andRouteAppendix:@"subscriptions"];
    
    ADMSubTypeDetailViewController *detailView = [[ADMSubTypeDetailViewController alloc] initWithAdminObject:adminObj AndProvider:_selectedProvider];
    
    detailView.dismissBlock = ^{
        [self fetchSubTypesInBackground];
    };
    
    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController:detailView];
    
    [self presentViewController:navControl animated:YES completion:nil];
}

- (void)customizeNavigationBar
{
    [[self navigationItem] setTitle:@"Subscription Types List"];
    
    UIBarButtonItem *addSubTypeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSubType:)];
    [[self navigationItem] setRightBarButtonItem:addSubTypeButton];
}

@end
